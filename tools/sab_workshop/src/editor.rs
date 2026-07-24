//! The mod-editor pages: **Strings**, **Objects**, **Icons**.
//!
//! These are three views onto ONE document — the mod — not three file editors. That distinction is
//! the whole design:
//!
//! * **The mod is the document.** It has a name and one output slot (`DLC/NN/`). The three pages
//!   edit different parts of the same thing, and they cross-reference each other (an icon added on
//!   the Icons page is what an Objects property points at).
//! * **Sources are read-only.** The game already loads `DLC/01/` as a full overlay — it mirrors the
//!   whole tree (megapacks, Cinematics, GameTemplates) — so a mod is naturally the next slot.
//!   Nothing here ever writes back over a retail file; publishing is additive and uninstalling is
//!   deleting a folder.
//! * **The changelist is the spine.** Every edit records what the value WAS, so revert is free and
//!   "what have I actually changed" is answerable at a glance. It spans all three pages because a
//!   real mod does.
//!
//! Two facts about the formats shape the UI more than any style choice:
//!
//! 1. **A UI string has no name on disk.** `GameText` stores `asset_id = pandemic_hash("File_Text.Key")`
//!    and an EMPTY key; the dotted id itself is never written. So strings cannot be grouped by
//!    namespace — you find them by searching their text, which is what a modder actually has. Where
//!    a template's `Name`/`Description` property points at a text hash, that template's name IS the
//!    string's name, and the cross-reference index recovers it.
//! 2. **A template property is four raw bytes.** The same word is a plausible int, float, or hash.
//!    Rather than make the modder pick a type before seeing anything, every reading is shown at once
//!    and the likeliest is lit.

use sab_formats::gametemplates::{Entry, GameTemplates};
use sab_formats::gametext::GameText;
use sab_formats::pandemic_hash;

use crate::dtex;
use crate::gui::theme;
use crate::pack::Megapack;

/// Which editor page is active.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum EdPage {
    Strings,
    Objects,
    Icons,
}

/// The language folders under `Cinematics/Dialog/`. A string edited in one is still retail in the
/// others — the likeliest way a mod ships half-broken, so coverage is always on screen.
const LANGS: [(&str, &str); 7] = [
    ("EN", "English"),
    ("FR", "French"),
    ("DE", "German"),
    ("IT", "Italian"),
    ("PL", "Polish"),
    ("RU", "Russian"),
    ("RND", "Random"),
];

// ---------------------------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------------------------

/// The mod being built: a name and one output overlay. Sources live in `game_dir` and are read-only.
struct Mod {
    name: String,
    game_dir: String,
    /// DLC slot to publish into. `01` is the game's own, so a mod takes the next free one.
    slot: String,
}

impl Mod {
    fn out_dir(&self) -> String {
        format!("{}/DLC/{}", self.game_dir, self.slot)
    }
    fn gametext_src(&self, lang: usize) -> String {
        format!("{}/Cinematics/Dialog/{}/GameText.dlg", self.game_dir, LANGS[lang].1)
    }
    fn gametext_out(&self, lang: usize) -> String {
        format!("{}/Cinematics/Dialog/{}/GameText.dlg", self.out_dir(), LANGS[lang].1)
    }
    /// Templates ship inside the DLC overlay, so the game's own `DLC/01` copy is the live source.
    fn templates_src(&self) -> String {
        format!("{}/DLC/01/GameTemplates.wsd", self.game_dir)
    }
    fn templates_out(&self) -> String {
        format!("{}/GameTemplates.wsd", self.out_dir())
    }
    fn palettes(&self) -> String {
        format!("{}/Global/Palettes0.megapack", self.game_dir)
    }
}

// ---------------------------------------------------------------------------------------------
// The changelist
// ---------------------------------------------------------------------------------------------

/// What a change does when published. Each carries enough to re-apply it to a freshly parsed source.
#[derive(Clone)]
enum Op {
    SetString { lang: usize, asset_id: u32, text: String },
    AddString { lang: usize, dotted: String, text: String },
    SetPair { entry: usize, pair: usize, bytes: Vec<u8> },
    /// Reserve a texture NAME so template properties can point at its hash before the DTEX exists.
    ReserveTexture { name: String },
}

impl Op {
    fn page(&self) -> EdPage {
        match self {
            Op::SetString { .. } | Op::AddString { .. } => EdPage::Strings,
            Op::SetPair { .. } => EdPage::Objects,
            Op::ReserveTexture { .. } => EdPage::Icons,
        }
    }
}

/// One reversible edit. `before` is kept so the changelist can always say what it was.
#[derive(Clone)]
struct Change {
    target: String,
    before: String,
    after: String,
    op: Op,
}

// ---------------------------------------------------------------------------------------------
// Per-page state
// ---------------------------------------------------------------------------------------------

/// An asset that loads ITSELF, off the UI thread.
///
/// There are no Load buttons in this editor. A page knowing which file it needs and then demanding
/// a click before fetching it is busywork — and doing that fetch on the UI thread is worse: the
/// megapack sweep is a ~700 MB read that froze the window outright ("Not Responding"). So every
/// page kicks its own load in the background and renders whatever state it is in.
enum Load<T> {
    Idle,
    Loading,
    Ready(T),
    Failed(String),
}

impl<T> Load<T> {
    fn ready(&self) -> Option<&T> {
        match self {
            Load::Ready(t) => Some(t),
            _ => None,
        }
    }
    fn ready_mut(&mut self) -> Option<&mut T> {
        match self {
            Load::Ready(t) => Some(t),
            _ => None,
        }
    }
}

/// One texture record found in the pack: name, its hash, and where to slice the bytes from.
type IconRec = (String, u32, usize, usize, usize);

/// Results streaming back from the loader threads.
enum EdMsg {
    Strings(usize, Result<GameText, String>),
    Objects(Result<GameTemplates, String>),
    IconProgress(usize, usize),
    Icons(Result<Vec<IconRec>, String>),
    /// hash, width, height, RGBA — decoded off-thread; the UI only uploads it.
    Thumb(u32, usize, usize, Vec<u8>),
}

#[derive(Default)]
struct StringsState {
    lang: usize,
    search: String,
    filter_ui: bool,
    filter_vo: bool,
    filter_edited: bool,
    selected: Option<usize>,
    edit_buf: String,
    new_id: String,
    new_text: String,
}

#[derive(Default)]
struct ObjectsState {
    search: String,
    selected: Option<usize>,
    /// pair index -> edit buffer, for the pair currently being typed into
    edit_pair: Option<usize>,
    edit_buf: String,
    /// set when a texture-valued property asked the Icons page for a value
    wiring: Option<(usize, usize)>,
}

#[derive(Default)]
struct IconsState {
    search: String,
    selected: Option<usize>,
    only_used: bool,
    new_name: String,
    /// entries swept / total, while the pack is being walked
    progress: (usize, usize),
}

/// Thumbnails, decoded on a worker and kept.
///
/// Decoding is NOT cheap even for a small picture: a DTEX stores its mips as zlib streams, so
/// reaching the 128px mip inflates the whole ~700 KB chain first — about 11 ms per texture. Doing
/// that for a screenful on the UI thread is a visible stall, and for the whole pool it is the freeze
/// this page used to have. So the UI never decodes: it asks, and uploads what comes back.
#[derive(Default)]
struct Thumbs {
    cache: std::collections::HashMap<u32, Option<egui::TextureHandle>>,
    /// asked for, still in flight — so a tile on screen for many frames is requested once
    pending: std::collections::HashSet<u32>,
    req: Option<std::sync::mpsc::Sender<ThumbReq>>,
}

/// (hash, megapack entry, offset, len) — where to find the record's bytes.
type ThumbReq = (u32, usize, usize, usize);

// ---------------------------------------------------------------------------------------------

pub struct Editor {
    md: Mod,
    changes: Vec<Change>,
    strings: StringsState,
    objects: ObjectsState,
    icons: IconsState,
    thumbs: Thumbs,
    /// value-hash -> template entry indices that reference it. Built from the parsed templates in one
    /// pass; serves BOTH pages — "which templates use this texture" and "which template names this
    /// string" are the same question asked of different hashes.
    xref: std::collections::HashMap<u32, Vec<usize>>,
    publish_note: String,

    // --- self-loading assets ---
    str_load: Load<GameText>,
    obj_load: Load<GameTemplates>,
    icon_load: Load<Vec<IconRec>>,
    tx: std::sync::mpsc::Sender<EdMsg>,
    rx: std::sync::mpsc::Receiver<EdMsg>,
}

impl Editor {
    pub fn new(game_dir: &str) -> Self {
        let (tx, rx) = std::sync::mpsc::channel();
        let mut e = Editor {
            md: Mod {
                name: "untitled_mod".into(),
                game_dir: game_dir.trim_end_matches(['/', '\\']).to_string(),
                slot: "02".into(),
            },
            changes: Vec::new(),
            strings: StringsState { filter_ui: true, filter_vo: true, ..Default::default() },
            objects: ObjectsState::default(),
            icons: IconsState::default(),
            thumbs: Thumbs::default(),
            xref: Default::default(),
            publish_note: String::new(),
            str_load: Load::Idle,
            obj_load: Load::Idle,
            icon_load: Load::Idle,
            tx,
            rx,
        };
        // Start everything now. Templates and one language are small and land almost immediately;
        // the pack sweep is the slow one and it runs alongside, so by the time anyone opens Icons it
        // is usually done — and if not, they see progress rather than a button.
        e.kick_strings();
        e.kick_objects();
        e.kick_icons();
        e
    }

    fn kick_strings(&mut self) {
        let (tx, lang, path) = (self.tx.clone(), self.strings.lang, self.md.gametext_src(self.strings.lang));
        self.str_load = Load::Loading;
        std::thread::spawn(move || {
            let r = std::fs::read(&path)
                .map_err(|e| format!("{path}: {e}"))
                .and_then(|b| GameText::parse(&b));
            let _ = tx.send(EdMsg::Strings(lang, r));
        });
    }

    fn kick_objects(&mut self) {
        let (tx, path) = (self.tx.clone(), self.md.templates_src());
        self.obj_load = Load::Loading;
        std::thread::spawn(move || {
            let r = std::fs::read(&path)
                .map_err(|e| format!("{path}: {e}"))
                .and_then(|b| GameTemplates::parse(&b).map(|(g, _)| g));
            let _ = tx.send(EdMsg::Objects(r));
        });
    }

    fn kick_icons(&mut self) {
        let (tx, path) = (self.tx.clone(), self.md.palettes());
        self.icon_load = Load::Loading;
        std::thread::spawn(move || {
            let r = (|| -> Result<Vec<IconRec>, String> {
                let mp = Megapack::open(&path)?;
                let total = mp.entries().len();
                let mut out = Vec::new();
                let mut seen = std::collections::HashSet::new();
                for (ei, e) in mp.entries().iter().enumerate() {
                    for (off, len, name) in dtex::find_records(mp.slice(e)) {
                        let h = pandemic_hash(&name);
                        if seen.insert(h) {
                            out.push((name, h, ei, off, len));
                        }
                    }
                    if ei % 16 == 0 {
                        let _ = tx.send(EdMsg::IconProgress(ei, total));
                    }
                }
                out.sort_by(|a, b| a.0.cmp(&b.0));
                Ok(out)
            })();
            let _ = tx.send(EdMsg::Icons(r));
        });
    }

    /// Drain the loader channel. Called once per frame before anything renders.
    pub fn pump(&mut self, ctx: &egui::Context) {
        while let Ok(m) = self.rx.try_recv() {
            match m {
                EdMsg::Strings(lang, r) => {
                    // A stale result from a language the user already switched away from.
                    if lang != self.strings.lang {
                        continue;
                    }
                    self.str_load = match r {
                        Ok(g) => Load::Ready(g),
                        Err(e) => Load::Failed(e),
                    };
                }
                EdMsg::Objects(r) => {
                    self.obj_load = match r {
                        Ok(g) => {
                            self.xref = build_xref(&g);
                            Load::Ready(g)
                        }
                        Err(e) => Load::Failed(e),
                    };
                }
                EdMsg::IconProgress(d, t) => self.icons.progress = (d, t),
                EdMsg::Icons(r) => {
                    self.icon_load = match r {
                        Ok(v) => {
                            self.start_thumb_worker();
                            Load::Ready(v)
                        }
                        Err(e) => Load::Failed(e),
                    };
                }
                EdMsg::Thumb(hash, w, h, rgba) => {
                    self.thumbs.pending.remove(&hash);
                    let img = egui::ColorImage::from_rgba_unmultiplied([w, h], &rgba);
                    let t = ctx.load_texture(
                        format!("ic{hash:08x}"),
                        img,
                        egui::TextureOptions::LINEAR,
                    );
                    self.thumbs.cache.insert(hash, Some(t));
                }
            }
        }
    }

    /// A persistent decoder thread. It owns its own mmap of the pack and answers requests; the UI
    /// thread never touches zlib or BC again, it only uploads finished RGBA.
    fn start_thumb_worker(&mut self) {
        if self.thumbs.req.is_some() {
            return;
        }
        let (rq_tx, rq_rx) = std::sync::mpsc::channel::<ThumbReq>();
        let out = self.tx.clone();
        let path = self.md.palettes();
        std::thread::spawn(move || {
            let Ok(mp) = Megapack::open(&path) else { return };
            while let Ok((hash, ei, off, len)) = rq_rx.recv() {
                let Some(e) = mp.entries().get(ei) else { continue };
                let sub = mp.slice(e);
                if off + len > sub.len() {
                    continue;
                }
                if let Ok(t) = dtex::decode_preview(&sub[off..off + len], 96) {
                    let _ = out.send(EdMsg::Thumb(
                        hash,
                        t.width as usize,
                        t.height as usize,
                        t.rgba,
                    ));
                }
            }
        });
        self.thumbs.req = Some(rq_tx);
    }

    /// The scanned texture records, or an empty slice while the sweep is still running.
    fn icon_recs(&self) -> &[IconRec] {
        match &self.icon_load {
            Load::Ready(v) => v,
            _ => &[],
        }
    }

    /// Render a not-yet-ready asset. Never a button — the load is already happening.
    fn load_state(&self, ui: &mut egui::Ui, what: &str, l: &Load<impl Sized>, prog: Option<(usize, usize)>) -> bool {
        match l {
            Load::Ready(_) => false,
            Load::Idle | Load::Loading => {
                ui.horizontal(|ui| {
                    ui.spinner();
                    ui.label(theme::data_text(format!("loading {what}…"), 10.5, theme::DIM));
                });
                if let Some((d, t)) = prog {
                    if t > 0 {
                        let (r, _) = ui.allocate_exact_size(
                            egui::vec2(ui.available_width().min(200.0), 3.0),
                            egui::Sense::hover(),
                        );
                        theme::meter_in(ui.painter(), r, d, t);
                        ui.label(theme::data_text(
                            format!("{d} of {t} bundles swept"),
                            9.5,
                            theme::FAINT,
                        ));
                    }
                }
                true
            }
            Load::Failed(e) => {
                ui.label(theme::data_text(format!("could not load {what}"), 11.0, theme::RED));
                ui.label(theme::data_text(e, 9.5, theme::FAINT));
                true
            }
        }
    }

    /// Pending edits on a page — the rail badge.
    pub fn pending(&self, page: EdPage) -> usize {
        self.changes.iter().filter(|c| c.op.page() == page).count()
    }

    pub fn total_pending(&self) -> usize {
        self.changes.len()
    }

    /// The command bar's mod chip: (name, output).
    pub fn mod_chip(&self) -> (String, String) {
        (self.md.name.clone(), format!("→ DLC/{}/", self.md.slot))
    }

    /// The status-bar line for a page.
    pub fn status(&self, page: EdPage) -> String {
        match page {
            EdPage::Strings => {
                let n = self.str_load.ready().map(|g| g.records.len()).unwrap_or(0);
                format!(
                    "{n} strings · {} · {} staged",
                    LANGS[self.strings.lang].0,
                    self.pending(EdPage::Strings)
                )
            }
            EdPage::Objects => {
                let n = self.obj_load.ready().map(|g| g.templates().count()).unwrap_or(0);
                format!("{n} templates · {} staged", self.pending(EdPage::Objects))
            }
            EdPage::Icons => format!(
                "{} records · {} referenced · {} staged",
                self.icon_recs().len(),
                self.icon_recs().iter().filter(|(_, h, _, _, _)| self.xref.contains_key(h)).count(),
                self.pending(EdPage::Icons)
            ),
        }
    }

    // ------------------------------------------------------------------ panels

    /// Left navigator for the active page.
    pub fn nav(&mut self, ui: &mut egui::Ui, page: EdPage) {
        match page {
            EdPage::Strings => self.strings_nav(ui),
            EdPage::Objects => self.objects_nav(ui),
            EdPage::Icons => self.icons_nav(ui),
        }
    }

    /// The work surface.
    pub fn central(&mut self, ctx: &egui::Context, page: EdPage) {
        egui::CentralPanel::default()
            .frame(
                egui::Frame::none()
                    .fill(theme::G0)
                    .inner_margin(egui::Margin::symmetric(16.0, 14.0)),
            )
            // No ScrollArea here: a page that needs one adds its own. Icons in particular must
            // virtualize (see `icons_central`), and a wrapping ScrollArea would defeat that by
            // making every tile lay out anyway.
            .show(ctx, |ui| match page {
                EdPage::Strings => {
                    egui::ScrollArea::vertical()
                        .auto_shrink([false, false])
                        .show(ui, |ui| self.strings_central(ui));
                }
                EdPage::Objects => {
                    egui::ScrollArea::vertical()
                        .auto_shrink([false, false])
                        .show(ui, |ui| self.objects_central(ui));
                }
                EdPage::Icons => self.icons_central(ui),
            });
    }

    /// Right rail: the page's context card, then the changelist — the spine, on every page.
    pub fn side(&mut self, ui: &mut egui::Ui, page: EdPage) {
        egui::ScrollArea::vertical().auto_shrink([false, false]).show(ui, |ui| {
            match page {
                EdPage::Strings => self.strings_context(ui),
                EdPage::Objects => self.objects_context(ui),
                EdPage::Icons => self.icons_context(ui),
            }
            ui.add_space(6.0);
            self.changelist(ui);
        });
    }

    // ------------------------------------------------------------------ changelist

    fn changelist(&mut self, ui: &mut egui::Ui) {
        theme::eyebrow(ui, "Changelist");
        ui.add_space(2.0);
        if self.changes.is_empty() {
            ui.label(theme::data_text(
                "Nothing staged yet. Every edit lands here with what it was, so it can always be undone.",
                10.5,
                theme::FAINT,
            ));
            return;
        }
        ui.label(theme::data_text(
            format!("{} change(s) across the mod", self.changes.len()),
            10.0,
            theme::FAINT,
        ));
        ui.add_space(4.0);

        let mut revert: Option<usize> = None;
        for (i, c) in self.changes.iter().enumerate() {
            let (tag, col) = match c.op.page() {
                EdPage::Strings => ("TEXT", theme::EMBER),
                EdPage::Objects => ("OBJ", theme::COLD),
                EdPage::Icons => ("ICON", theme::DIM),
            };
            egui::Frame::none()
                .fill(theme::G2)
                .stroke(egui::Stroke::new(1.0, theme::LINE))
                .inner_margin(egui::Margin::symmetric(8.0, 6.0))
                .outer_margin(egui::Margin { bottom: 5.0, ..Default::default() })
                .show(ui, |ui| {
                    ui.horizontal(|ui| {
                        ui.label(theme::disp_text(tag, 9.5, col));
                        ui.label(theme::data_text(&c.target, 10.5, theme::TX));
                        ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                            if ui
                                .add(
                                    egui::Button::new(theme::disp_text("↺", 11.0, theme::FAINT))
                                        .frame(false),
                                )
                                .on_hover_text("revert this change")
                                .clicked()
                            {
                                revert = Some(i);
                            }
                        });
                    });
                    // before → after, in the two colours the theme already uses for
                    // "the game's value" and "yours".
                    ui.horizontal_wrapped(|ui| {
                        ui.spacing_mut().item_spacing.x = 4.0;
                        if !c.before.is_empty() {
                            ui.label(theme::data_text(trunc(&c.before, 26), 9.5, theme::COLD));
                            ui.label(theme::data_text("→", 9.5, theme::FAINT));
                        }
                        ui.label(theme::data_text(trunc(&c.after, 26), 9.5, theme::EMBER));
                    });
                });
        }
        if let Some(i) = revert {
            let c = self.changes.remove(i);
            self.unapply(&c);
        }

        ui.add_space(4.0);
        ui.horizontal(|ui| {
            if ui.add(egui::Button::new(theme::disp_text("Revert all", 11.0, theme::TX))).clicked() {
                let all: Vec<Change> = self.changes.drain(..).collect();
                for c in all.iter().rev() {
                    self.unapply(c);
                }
            }
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                if theme::stamp_button(ui, "Publish", !self.changes.is_empty())
                    .on_hover_text(format!(
                        "Write {} — a fresh overlay beside the game's own DLC/01/. Sources are never touched.",
                        self.md.out_dir()
                    ))
                    .clicked()
                {
                    self.publish();
                }
            });
        });
        if !self.publish_note.is_empty() {
            ui.add_space(4.0);
            let col = if self.publish_note.starts_with("published") { theme::EMBER } else { theme::RED };
            ui.label(theme::data_text(&self.publish_note, 10.0, col));
        }
        ui.add_space(3.0);
        ui.label(theme::data_text(
            format!("publishes to {}", self.md.out_dir()),
            9.5,
            theme::FAINT,
        ));
    }

    /// Undo a change's effect on the in-memory model (the changelist entry itself is already gone).
    fn unapply(&mut self, c: &Change) {
        match &c.op {
            Op::SetString { asset_id, .. } => {
                if let Some(gt) = self.str_load.ready_mut() {
                    if let Some(r) = gt.find_mut(*asset_id) {
                        r.set_text(&c.before);
                    }
                }
                self.strings.edit_buf = c.before.clone();
            }
            Op::AddString { dotted, .. } => {
                let id = pandemic_hash(dotted);
                if let Some(gt) = self.str_load.ready_mut() {
                    gt.records.retain(|r| r.asset_id != id);
                }
            }
            Op::SetPair { entry, pair, .. } => {
                // `before` is the display form; re-encode from the raw we stored alongside it.
                if let Some(gt) = self.obj_load.ready_mut() {
                    if let Some(Entry::Template(t)) = gt.entries.get_mut(*entry) {
                        if let Some(p) = t.pairs.get_mut(*pair) {
                            if let Ok(b) = parse_u32_any(&c.before) {
                                p.data = b.to_le_bytes().to_vec();
                            }
                        }
                    }
                }
            }
            Op::ReserveTexture { .. } => {}
        }
    }

    fn stage(&mut self, target: String, before: String, after: String, op: Op) {
        // One entry per target: re-editing the same thing updates it and keeps the ORIGINAL before,
        // so the changelist always compares against retail, not against your last keystroke.
        if let Some(existing) = self.changes.iter_mut().find(|c| c.target == target) {
            existing.after = after;
            existing.op = op;
            return;
        }
        self.changes.push(Change { target, before, after, op });
    }

    // ------------------------------------------------------------------ publish

    /// Write the overlay. Every source is re-read fresh and every change re-applied, so publishing
    /// is a pure function of (sources, changelist) — it can be run twice and never compounds.
    fn publish(&mut self) {
        let out = self.md.out_dir();
        let mut wrote: Vec<String> = Vec::new();

        // ---- strings, per language ----
        for lang in 0..LANGS.len() {
            let ops: Vec<&Op> = self
                .changes
                .iter()
                .map(|c| &c.op)
                .filter(|o| matches!(o, Op::SetString { lang: l, .. } | Op::AddString { lang: l, .. } if *l == lang))
                .collect();
            if ops.is_empty() {
                continue;
            }
            let src = self.md.gametext_src(lang);
            let Ok(bytes) = std::fs::read(&src) else {
                self.publish_note = format!("cannot read {src}");
                return;
            };
            let Ok(mut gt) = GameText::parse(&bytes) else {
                self.publish_note = format!("cannot parse {src}");
                return;
            };
            for op in ops {
                match op {
                    Op::SetString { asset_id, text, .. } => {
                        if let Some(r) = gt.find_mut(*asset_id) {
                            r.set_text(text);
                        }
                    }
                    Op::AddString { dotted, text, .. } => {
                        let _ = gt.add_ui(dotted, text);
                    }
                    _ => {}
                }
            }
            let dst = self.md.gametext_out(lang);
            if let Some(p) = std::path::Path::new(&dst).parent() {
                let _ = std::fs::create_dir_all(p);
            }
            match std::fs::write(&dst, gt.write()) {
                Ok(_) => wrote.push(format!("{}/GameText.dlg", LANGS[lang].1)),
                Err(e) => {
                    self.publish_note = format!("write {dst}: {e}");
                    return;
                }
            }
        }

        // ---- templates ----
        let pair_ops: Vec<(usize, usize, Vec<u8>)> = self
            .changes
            .iter()
            .filter_map(|c| match &c.op {
                Op::SetPair { entry, pair, bytes } => Some((*entry, *pair, bytes.clone())),
                _ => None,
            })
            .collect();
        if !pair_ops.is_empty() {
            let src = self.md.templates_src();
            let Ok(bytes) = std::fs::read(&src) else {
                self.publish_note = format!("cannot read {src}");
                return;
            };
            let Ok((mut gt, _)) = GameTemplates::parse(&bytes) else {
                self.publish_note = format!("cannot parse {src}");
                return;
            };
            for (e, p, b) in pair_ops {
                if let Some(Entry::Template(t)) = gt.entries.get_mut(e) {
                    if let Some(pp) = t.pairs.get_mut(p) {
                        pp.data = b;
                    }
                }
            }
            let dst = self.md.templates_out();
            if let Some(pp) = std::path::Path::new(&dst).parent() {
                let _ = std::fs::create_dir_all(pp);
            }
            match std::fs::write(&dst, gt.write()) {
                Ok(_) => wrote.push("GameTemplates.wsd".into()),
                Err(e) => {
                    self.publish_note = format!("write {dst}: {e}");
                    return;
                }
            }
        }

        // ---- reserved texture names ----
        // A reservation is a NAME, not pixels: the hash is what a template points at, and packing the
        // DTEX itself belongs to sab_dtex / sab_sbla. Record it so the chain is documented rather
        // than silently missing.
        let reserved: Vec<&str> = self
            .changes
            .iter()
            .filter_map(|c| match &c.op {
                Op::ReserveTexture { name } => Some(name.as_str()),
                _ => None,
            })
            .collect();
        if !reserved.is_empty() {
            let mut s = String::from("# textures this mod expects, and the hash a template uses\n");
            for n in &reserved {
                s.push_str(&format!("{n}\t0x{:08X}\n", pandemic_hash(n)));
            }
            let dst = format!("{out}/textures.wanted.tsv");
            let _ = std::fs::create_dir_all(&out);
            if std::fs::write(&dst, s).is_ok() {
                wrote.push("textures.wanted.tsv".into());
            }
        }

        self.publish_note = if wrote.is_empty() {
            "nothing to write".into()
        } else {
            format!("published → {} ({})", out, wrote.join(", "))
        };
    }

    // ============================================================== STRINGS

    fn strings_nav(&mut self, ui: &mut egui::Ui) {
        theme::eyebrow(ui, "Language");
        ui.add_space(3.0);
        // Coverage: which languages this mod has touched. A string changed in EN is still retail in
        // the other six, and that was previously invisible.
        // Painted rather than laid out: seven fixed cells that always read as one strip, whatever
        // width the panel is dragged to. (A Frame per language stretches to fill the row.)
        let mut switch_to: Option<usize> = None;
        let cell_w = 40.0;
        let cell_h = 36.0;
        let (strip, _) = ui.allocate_exact_size(
            egui::vec2(cell_w * LANGS.len() as f32 + 6.0 * (LANGS.len() - 1) as f32, cell_h),
            egui::Sense::hover(),
        );
        for (i, (short, full)) in LANGS.iter().enumerate() {
            let edits = self
                .changes
                .iter()
                .filter(|c| {
                    matches!(&c.op, Op::SetString { lang, .. } | Op::AddString { lang, .. } if *lang == i)
                })
                .count();
            let r = egui::Rect::from_min_size(
                strip.min + egui::vec2((cell_w + 6.0) * i as f32, 0.0),
                egui::vec2(cell_w, cell_h),
            );
            let resp = ui.interact(r, ui.id().with(("lang", i)), egui::Sense::click());
            let on = self.strings.lang == i;
            let (fill, stroke, fg) = if on {
                (theme::RED_SOFT, theme::RED, theme::RED)
            } else if edits > 0 {
                (theme::EMBER_SOFT, theme::EMBER_DK, theme::EMBER)
            } else {
                (theme::G2, theme::LINE, theme::FAINT)
            };
            let p = ui.painter();
            p.rect_filled(r, egui::Rounding::ZERO, fill);
            p.rect_stroke(r, egui::Rounding::ZERO, egui::Stroke::new(1.0, stroke));
            p.text(
                r.center() - egui::vec2(0.0, 6.0),
                egui::Align2::CENTER_CENTER,
                short,
                egui::FontId::new(10.0, theme::disp()),
                fg,
            );
            // a filled bar = this language carries edits; empty = still retail
            let bar = egui::Rect::from_min_size(
                egui::pos2(r.left() + 6.0, r.bottom() - 9.0),
                egui::vec2(cell_w - 12.0, 3.0),
            );
            p.rect_filled(bar, egui::Rounding::ZERO, theme::G3);
            if edits > 0 {
                p.rect_filled(bar, egui::Rounding::ZERO, theme::EMBER);
            }
            if resp.clicked() {
                switch_to = Some(i);
            }
            resp.on_hover_text(format!("{full} — {edits} edit(s) in this mod"));
        }
        if let Some(i) = switch_to {
            if self.strings.lang != i {
                self.strings.lang = i;
                self.strings.selected = None;
                self.kick_strings(); // switching language just loads it
            }
        }

        ui.add_space(8.0);
        theme::eyebrow(ui, "Strings");
        ui.add_space(3.0);

        if self.load_state(ui, LANGS[self.strings.lang].1, &self.str_load, None) {
            ui.add_space(4.0);
            ui.label(theme::data_text(
                "source is read-only; edits publish to the DLC overlay",
                9.5,
                theme::FAINT,
            ));
            return;
        }

        // Own the model for the rest of the frame so it does not alias the `&mut self` calls below
        // (staging, selection). Restored before returning — the guard above already proved it Ready.
        let loaded = std::mem::replace(&mut self.str_load, Load::Loading);
        let Load::Ready(gt) = &loaded else { self.str_load = loaded; return; };

        // filters
        ui.horizontal(|ui| {
            if theme::pill(ui, "ui", self.strings.filter_ui).clicked() {
                self.strings.filter_ui = !self.strings.filter_ui;
            }
            if theme::pill(ui, "vo", self.strings.filter_vo).clicked() {
                self.strings.filter_vo = !self.strings.filter_vo;
            }
            if theme::pill(ui, "edited", self.strings.filter_edited).clicked() {
                self.strings.filter_edited = !self.strings.filter_edited;
            }
        });
        ui.horizontal(|ui| {
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                if ui.button("✕").clicked() {
                    self.strings.search.clear();
                }
                ui.add_sized(
                    [ui.available_width(), 20.0],
                    egui::TextEdit::singleline(&mut self.strings.search)
                        .hint_text("search the text itself"),
                );
            });
        });

        
        let needle = self.strings.search.to_ascii_lowercase();
        let edited: std::collections::HashSet<u32> = self
            .changes
            .iter()
            .filter_map(|c| match &c.op {
                Op::SetString { asset_id, lang, .. } if *lang == self.strings.lang => Some(*asset_id),
                _ => None,
            })
            .collect();

        let rows: Vec<usize> = gt
            .records
            .iter()
            .enumerate()
            .filter(|(_, r)| {
                let is_ui = r.is_ui();
                if is_ui && !self.strings.filter_ui {
                    return false;
                }
                if !is_ui && !self.strings.filter_vo {
                    return false;
                }
                if self.strings.filter_edited && !edited.contains(&r.asset_id) {
                    return false;
                }
                if needle.is_empty() {
                    return true;
                }
                r.text_string().to_ascii_lowercase().contains(&needle)
                    || format!("{:08x}", r.asset_id).contains(&needle)
                    || r.key_str().to_ascii_lowercase().contains(&needle)
            })
            .map(|(i, _)| i)
            .collect();

        ui.label(theme::data_text(
            format!("{} of {} shown", rows.len(), gt.records.len()),
            10.0,
            theme::FAINT,
        ));
        ui.add_space(3.0);

        let mut pick: Option<usize> = None;
        egui::ScrollArea::vertical().id_source("str_rows").auto_shrink([false, false]).show_rows(
            ui,
            20.0,
            rows.len(),
            |ui, range| {
                for k in range {
                    let i = rows[k];
                    let r = &gt.records[i];
                    let sel = self.strings.selected == Some(i);
                    let is_edited = edited.contains(&r.asset_id);
                    ui.horizontal(|ui| {
                        let (d, _) =
                            ui.allocate_exact_size(egui::vec2(6.0, 6.0), egui::Sense::hover());
                        ui.painter().rect_filled(
                            d,
                            egui::Rounding::ZERO,
                            if is_edited { theme::EMBER } else { theme::G3 },
                        );
                        let fg = if sel {
                            theme::RED
                        } else if is_edited {
                            theme::TX
                        } else {
                            theme::DIM
                        };
                        // The TEXT is the identifier a modder actually has, so it leads.
                        let label = trunc(&r.text_string(), 40);
                        if ui
                            .add(
                                egui::Label::new(theme::data_text(label, 11.0, fg))
                                    .sense(egui::Sense::click()),
                            )
                            .clicked()
                        {
                            pick = Some(i);
                        }
                        ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                            ui.label(theme::disp_text(
                                if r.is_ui() { "ui" } else { "vo" },
                                9.0,
                                theme::FAINT,
                            ));
                        });
                    });
                }
            },
        );
        if let Some(i) = pick {
            self.strings.selected = Some(i);
            self.strings.edit_buf = gt.records[i].text_string();
        }
        self.str_load = loaded; // hand the model back
    }

    fn strings_central(&mut self, ui: &mut egui::Ui) {
        if self.str_load.ready().is_none() {
            self.empty_state(
                ui,
                "Strings",
                "Everything the player reads — objectives, mission names, shop items, subtitles.",
                &[
                    "A UI string has NO name on disk: the file stores pandemic_hash(\"File_Text.Key\") and an empty key, so the dotted id is gone. You find a string by searching the text you can see in-game.",
                    "Nothing to press: the language on the left is fetched in the background the moment you pick it.",
                ],
            );
            return;
        }

        // Own the model for the rest of the frame so it does not alias the `&mut self` calls below
        // (staging, selection). Restored before returning — the guard above already proved it Ready.
        let loaded = std::mem::replace(&mut self.str_load, Load::Loading);
        let Load::Ready(gt) = &loaded else { self.str_load = loaded; return; };
        
        let sel = self.strings.selected;

        if let Some(i) = sel.and_then(|i| if i < gt.records.len() { Some(i) } else { None }) {
            let r = &gt.records[i];
            let orig = self.original_text(r.asset_id).unwrap_or_else(|| r.text_string());
            let is_ui = r.is_ui();

            ui.label(theme::data_text(
                format!(
                    "0x{:08X} · {}",
                    r.asset_id,
                    if is_ui { "UI string" } else { "VO subtitle" }
                ),
                9.5,
                theme::RED_DK,
            ));
            // A template that points at this hash NAMES it — the only way an anonymous UI string
            // gets a human label back.
            let named = self.xref.get(&r.asset_id).cloned().unwrap_or_default();
            let title = if let Some(n) = named.first().and_then(|e| self.template_name(*e)) {
                n
            } else if !r.key_str().is_empty() {
                r.key_str()
            } else {
                format!("string 0x{:08X}", r.asset_id)
            };
            ui.label(theme::poster_text(title, 21.0, theme::TX));
            ui.add_space(10.0);

            theme::eyebrow(ui, "The string");
            ui.add_space(4.0);
            // was / now — the core widget.
            egui::Frame::none()
                .fill(theme::COLD_SOFT)
                .stroke(egui::Stroke::new(1.0, theme::LINE))
                .inner_margin(egui::Margin::symmetric(11.0, 8.0))
                .show(ui, |ui| {
                    ui.horizontal_top(|ui| {
                        ui.label(theme::disp_text("Retail", 9.5, theme::COLD));
                        ui.add_space(6.0);
                        ui.label(theme::data_text(&orig, 12.0, theme::DIM));
                    });
                });
            egui::Frame::none()
                .fill(theme::EMBER_SOFT)
                .stroke(egui::Stroke::new(1.0, theme::EMBER_DK))
                .inner_margin(egui::Margin::symmetric(11.0, 8.0))
                .show(ui, |ui| {
                    ui.horizontal_top(|ui| {
                        ui.label(theme::disp_text("Yours", 9.5, theme::EMBER));
                        ui.add_space(6.0);
                        ui.add(
                            egui::TextEdit::multiline(&mut self.strings.edit_buf)
                                .desired_width(f32::INFINITY)
                                .desired_rows(3)
                                .font(egui::FontId::new(12.0, theme::data())),
                        );
                    });
                });

            ui.add_space(8.0);
            ui.horizontal(|ui| {
                theme::chip(ui, &format!("{} chars", self.strings.edit_buf.chars().count()), false, None);
                let changed = self.strings.edit_buf != orig;
                if changed {
                    theme::chip(ui, "unsaved", true, None);
                }
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    if theme::primary_button(ui, "Stage", changed).clicked() {
                        let after = self.strings.edit_buf.clone();
                        let id = r.asset_id;
                        self.stage(
                            format!("{} · 0x{:08X}", LANGS[self.strings.lang].0, id),
                            orig.clone(),
                            after.clone(),
                            Op::SetString { lang: self.strings.lang, asset_id: id, text: after },
                        );
                    }
                    if ui
                        .add_enabled(changed, egui::Button::new(theme::disp_text("Revert", 11.5, theme::TX)))
                        .clicked()
                    {
                        self.strings.edit_buf = orig.clone();
                        let key = format!("{} · 0x{:08X}", LANGS[self.strings.lang].0, r.asset_id);
                        if let Some(p) = self.changes.iter().position(|c| c.target == key) {
                            let c = self.changes.remove(p);
                            self.unapply(&c);
                        }
                    }
                });
            });
        } else {
            self.empty_state(
                ui,
                "Pick a string",
                "Search the text on the left — that's the handle you have, because the id itself isn't stored.",
                &[],
            );
        }

        // add-new, always available
        ui.add_space(16.0);
        theme::card(ui, "Add a string", None, |ui| {
            ui.horizontal(|ui| {
                ui.label(theme::disp_text("Id", 11.0, theme::DIM));
                ui.add_sized(
                    [260.0, 20.0],
                    egui::TextEdit::singleline(&mut self.strings.new_id)
                        .hint_text("MyMod_Text.MyKey"),
                );
            });
            ui.horizontal(|ui| {
                ui.label(theme::disp_text("Text", 11.0, theme::DIM));
                ui.add_sized(
                    [340.0, 20.0],
                    egui::TextEdit::singleline(&mut self.strings.new_text),
                );
            });
            if !self.strings.new_id.is_empty() {
                let h = pandemic_hash(&self.strings.new_id);
                let clash = gt.find(h).is_some();
                ui.label(theme::data_text(
                    format!("→ 0x{h:08X}{}", if clash { "  ·  ALREADY EXISTS" } else { "" }),
                    10.5,
                    if clash { theme::RED } else { theme::COLD },
                ));
                if clash {
                    ui.label(theme::data_text(
                        "that id is taken — staging this would overwrite the existing line",
                        10.0,
                        theme::RED,
                    ));
                }
                if theme::primary_button(ui, "Stage new string", !clash).clicked() {
                    let dotted = self.strings.new_id.clone();
                    let text = self.strings.new_text.clone();
                    self.stage(
                        format!("{} · +{}", LANGS[self.strings.lang].0, dotted),
                        String::new(),
                        text.clone(),
                        Op::AddString { lang: self.strings.lang, dotted, text },
                    );
                    self.strings.new_id.clear();
                    self.strings.new_text.clear();
                }
            }
        });

        
        self.str_load = loaded; // hand the model back
    }

    fn strings_context(&mut self, ui: &mut egui::Ui) {
        let id = self
            .strings
            .selected
            .and_then(|i| self.str_load.ready().and_then(|g| g.records.get(i)))
            .map(|r| r.asset_id);
        theme::card(ui, "Coverage", None, |ui| {
            match id {
                None => {
                    ui.label(theme::data_text("No string selected.", 10.5, theme::FAINT));
                }
                Some(id) => {
                    let done: Vec<&str> = LANGS
                        .iter()
                        .enumerate()
                        .filter(|(i, _)| {
                            self.changes.iter().any(|c| {
                                matches!(&c.op, Op::SetString { lang, asset_id, .. }
                                    if *lang == *i && *asset_id == id)
                            })
                        })
                        .map(|(_, l)| l.0)
                        .collect();
                    ui.label(theme::data_text(
                        format!("{} of 7 languages", done.len()),
                        11.0,
                        if done.len() == LANGS.len() { theme::EMBER } else { theme::TX },
                    ));
                    ui.label(theme::data_text(
                        if done.is_empty() { "none yet".into() } else { done.join(" ") },
                        10.0,
                        theme::EMBER,
                    ));
                    if done.len() < LANGS.len() && !done.is_empty() {
                        ui.label(theme::data_text(
                            "players in the rest still see the retail line",
                            10.0,
                            theme::FAINT,
                        ));
                    }
                }
            }
        });
        if let Some(id) = id {
            let refs = self.xref.get(&id).cloned().unwrap_or_default();
            theme::card(ui, "Named by", Some(&refs.len().to_string()), |ui| {
                if refs.is_empty() {
                    ui.label(theme::data_text(
                        "No template points at this hash, so there is no name to recover — the dotted id was never written to disk.",
                        10.0,
                        theme::FAINT,
                    ));
                } else {
                    for e in refs.iter().take(6) {
                        if let Some(n) = self.template_name(*e) {
                            ui.label(theme::data_text(n, 10.5, theme::TX));
                        }
                    }
                }
            });
        }
    }

    /// The retail text for an id: the `before` of a staged change, else what's in memory.
    fn original_text(&self, asset_id: u32) -> Option<String> {
        if let Some(c) = self.changes.iter().find(|c| {
            matches!(&c.op, Op::SetString { asset_id: a, lang, .. }
                if *a == asset_id && *lang == self.strings.lang)
        }) {
            return Some(c.before.clone());
        }
        self.str_load.ready().and_then(|g| g.find(asset_id)).map(|r| r.text_string())
    }

    // ============================================================== OBJECTS

    fn objects_nav(&mut self, ui: &mut egui::Ui) {
        theme::eyebrow(ui, "Templates");
        ui.add_space(3.0);
        if self.load_state(ui, "GameTemplates.wsd", &self.obj_load, None) {
            return;
        }

        let loaded = std::mem::replace(&mut self.obj_load, Load::Loading);
        let Load::Ready(gt) = &loaded else { self.obj_load = loaded; return; };
        ui.horizontal(|ui| {
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                if ui.button("✕").clicked() {
                    self.objects.search.clear();
                }
                ui.add_sized(
                    [ui.available_width(), 20.0],
                    egui::TextEdit::singleline(&mut self.objects.search).hint_text("name or type"),
                );
            });
        });

        
        let needle = self.objects.search.to_ascii_lowercase();
        let edited: std::collections::HashSet<usize> = self
            .changes
            .iter()
            .filter_map(|c| match &c.op {
                Op::SetPair { entry, .. } => Some(*entry),
                _ => None,
            })
            .collect();

        // group by type — the field that says what kind of thing a template is
        let mut by_type: std::collections::BTreeMap<String, Vec<(usize, String)>> = Default::default();
        for (i, e) in gt.entries.iter().enumerate() {
            if let Entry::Template(t) = e {
                let hay = format!("{} {}", t.name, t.ttype).to_ascii_lowercase();
                if !needle.is_empty() && !hay.contains(&needle) {
                    continue;
                }
                by_type.entry(t.ttype.clone()).or_default().push((i, t.name.clone()));
            }
        }
        let shown: usize = by_type.values().map(|v| v.len()).sum();
        ui.label(theme::data_text(
            format!("{shown} of {} templates", gt.templates().count()),
            10.0,
            theme::FAINT,
        ));
        ui.add_space(3.0);

        let mut pick = None;
        egui::ScrollArea::vertical().id_source("obj_rows").auto_shrink([false, false]).show(ui, |ui| {
            for (ty, items) in &by_type {
                ui.horizontal(|ui| {
                    ui.label(theme::disp_text(ty, 10.5, theme::FAINT));
                    ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                        ui.label(theme::data_text(format!("{}", items.len()), 9.5, theme::FAINT));
                    });
                });
                for (i, name) in items.iter().take(400) {
                    let sel = self.objects.selected == Some(*i);
                    let is_ed = edited.contains(i);
                    ui.horizontal(|ui| {
                        let (d, _) = ui.allocate_exact_size(egui::vec2(6.0, 6.0), egui::Sense::hover());
                        ui.painter().rect_filled(
                            d,
                            egui::Rounding::ZERO,
                            if is_ed { theme::EMBER } else { theme::G3 },
                        );
                        let fg = if sel { theme::RED } else if is_ed { theme::TX } else { theme::DIM };
                        if ui
                            .add(egui::Label::new(theme::data_text(name, 11.0, fg)).sense(egui::Sense::click()))
                            .clicked()
                        {
                            pick = Some(*i);
                        }
                    });
                }
                if items.len() > 400 {
                    ui.label(theme::data_text(
                        format!("… {} more — narrow the filter", items.len() - 400),
                        9.5,
                        theme::FAINT,
                    ));
                }
            }
        });
        if let Some(i) = pick {
            self.objects.selected = Some(i);
            self.objects.edit_pair = None;
        }
        
        self.obj_load = loaded; // hand the model back
    }

    /// One pass over every pair: any 4-byte value is a candidate hash, so index value → templates.
    /// This is what lets the Icons page say "used by" and the Strings page recover a name.
    fn template_name(&self, entry: usize) -> Option<String> {
        match self.obj_load.ready()?.entries.get(entry) {
            Some(Entry::Template(t)) => Some(t.name.clone()),
            _ => None,
        }
    }

    /// What a 4-byte value POINTS AT, if anything.
    ///
    /// A hash is only meaningful once you know what it names, and the workshop already holds every
    /// corpus needed to find out: the texture pool, the template list, and the loaded language's
    /// strings. Resolving turns `1215273707` into `"Brothel Hat"` — which is the difference between
    /// a hex editor and a tool.
    fn resolve_hash(&self, v: u32) -> Option<(&'static str, String)> {
        if let Some((n, _, _, _, _)) = self.icon_recs().iter().find(|(_, h, _, _, _)| *h == v) {
            return Some(("texture", n.clone()));
        }
        if let Some(gt) = self.str_load.ready() {
            if let Some(r) = gt.find(v) {
                return Some(("string", r.text_string()));
            }
        }
        if let Some(gt) = self.obj_load.ready() {
            for e in &gt.entries {
                if let Entry::Template(t) = e {
                    if pandemic_hash(&t.name) == v {
                        return Some(("template", t.name.clone()));
                    }
                }
            }
        }
        None
    }

    /// Known properties whose value is a reference, not a number. Showing `245355.672f` for a Name
    /// is worse than useless — it invites someone to "fix" a float that was never a float.
    fn is_ref_property(name: &str) -> bool {
        matches!(
            name,
            "Name" | "Description" | "Image" | "Texture" | "Model" | "Face" | "Head" | "Skin"
        )
    }

    fn objects_central(&mut self, ui: &mut egui::Ui) {
        if self.obj_load.ready().is_none() {
            self.empty_state(
                ui,
                "Objects",
                "Every thing in the game is a template: a bag of {property → value} pairs.",
                &[
                    "A property name is a hash too, and only fifteen are known, so most show as 0x…. A value is four raw bytes that could be an int, a float, or a hash — every reading is shown at once so you can recognise the real one instead of guessing.",
                    "The game's own DLC/01/GameTemplates.wsd is the source, and it is already being read — nothing to press.",
                ],
            );
            return;
        }

        let loaded = std::mem::replace(&mut self.obj_load, Load::Loading);
        let Load::Ready(gt) = &loaded else { self.obj_load = loaded; return; };
        
        let sel = self.objects.selected;

        match sel.and_then(|i| match gt.entries.get(i) {
            Some(Entry::Template(t)) => Some((i, t)),
            _ => None,
        }) {
            None => self.empty_state(ui, "Pick a template", "Choose one on the left.", &[]),
            Some((idx, t)) => {
                let n_edit = self
                    .changes
                    .iter()
                    .filter(|c| matches!(&c.op, Op::SetPair { entry, .. } if *entry == idx))
                    .count();
                ui.label(theme::data_text(
                    format!("{} · {} properties · {} changed", t.ttype, t.pairs.len(), n_edit),
                    9.5,
                    theme::RED_DK,
                ));
                ui.label(theme::poster_text(&t.name, 21.0, theme::TX));
                ui.add_space(10.0);

                // known first — they get a real label
                let mut known: Vec<usize> = Vec::new();
                let mut unknown: Vec<usize> = Vec::new();
                for (pi, p) in t.pairs.iter().enumerate() {
                    if sab_formats::gametemplates::known_property_name(p.hash).is_some() {
                        known.push(pi)
                    } else {
                        unknown.push(pi)
                    }
                }

                let mut act: Option<(usize, Vec<u8>, String, String)> = None; // (pair, bytes, before, after)
                let mut wire: Option<usize> = None;

                if !known.is_empty() {
                    theme::eyebrow(ui, "Named properties");
                    ui.add_space(4.0);
                    for pi in known {
                        let p = &t.pairs[pi];
                        let name = sab_formats::gametemplates::known_property_name(p.hash).unwrap();
                        self.prop_row(ui, idx, pi, name, p, &mut act, &mut wire);
                    }
                }
                if !unknown.is_empty() {
                    ui.add_space(10.0);
                    theme::eyebrow(ui, "Unnamed properties");
                    ui.add_space(2.0);
                    ui.label(theme::data_text(
                        "the property name is a hash we can't spell yet — every reading of the value is shown so the real one is recognisable",
                        10.0,
                        theme::FAINT,
                    ));
                    ui.add_space(4.0);
                    for pi in unknown.into_iter().take(60) {
                        let p = &t.pairs[pi];
                        let label = format!("0x{:08X}", p.hash);
                        self.prop_row(ui, idx, pi, &label, p, &mut act, &mut wire);
                    }
                }

                if let Some((pi, bytes, before, after)) = act {
                    let tname = t.name.clone();
                    self.stage(
                        format!("{tname} · pair {pi}"),
                        before,
                        after,
                        Op::SetPair { entry: idx, pair: pi, bytes },
                    );
                }
                if let Some(pi) = wire {
                    self.objects.wiring = Some((idx, pi));
                }
            }
        }
        
        self.obj_load = loaded; // hand the model back
    }

    /// One property row. A texture-valued property shows the icon and offers the picker; everything
    /// else is an editable value with its four readings underneath when it is not a known type.
    #[allow(clippy::too_many_arguments)]
    fn prop_row(
        &mut self,
        ui: &mut egui::Ui,
        entry: usize,
        pi: usize,
        name: &str,
        p: &sab_formats::gametemplates::Pair,
        act: &mut Option<(usize, Vec<u8>, String, String)>,
        wire: &mut Option<usize>,
    ) {
        let staged = self
            .changes
            .iter()
            .find(|c| matches!(&c.op, Op::SetPair { entry: e, pair, .. } if *e == entry && *pair == pi));
        let edited = staged.is_some();
        let val = p.as_u32();
        let known = sab_formats::gametemplates::known_property_name(p.hash).is_some();
        let is_ref = known && Self::is_ref_property(name);
        // What this value points at, if we can tell.
        let resolved = val.and_then(|v| self.resolve_hash(v));
        // A texture reference gets the picker; anything else that resolves just gets named.
        let tex = match &resolved {
            Some(("texture", n)) => Some(n.clone()),
            _ => None,
        };

        egui::Frame::none()
            .fill(if edited { theme::EMBER_SOFT } else { theme::G2 })
            .stroke(egui::Stroke::new(1.0, if edited { theme::EMBER_DK } else { theme::LINE }))
            .inner_margin(egui::Margin::symmetric(9.0, 6.0))
            .outer_margin(egui::Margin { bottom: 4.0, ..Default::default() })
            .show(ui, |ui| {
                ui.horizontal(|ui| {
                    ui.label(theme::disp_text(
                        name,
                        11.0,
                        if edited { theme::EMBER } else { theme::DIM },
                    ));
                    ui.add_space(4.0);

                    if let Some(tn) = &tex {
                        ui.label(theme::data_text(tn, 11.0, theme::TX));
                        ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                            if ui
                                .add(egui::Button::new(theme::disp_text("Pick ▦", 9.5, theme::COLD)))
                                .on_hover_text("choose a texture on the Icons page")
                                .clicked()
                            {
                                *wire = Some(pi);
                            }
                        });
                    } else {
                        // editable value
                        let is_open = self.objects.edit_pair == Some(pi);
                        if is_open {
                            let r = ui.add_sized(
                                [160.0, 20.0],
                                egui::TextEdit::singleline(&mut self.objects.edit_buf)
                                    .font(egui::FontId::new(11.5, theme::data())),
                            );
                            if r.lost_focus() && ui.input(|i| i.key_pressed(egui::Key::Enter)) {
                                if let Ok(v) = parse_u32_any(&self.objects.edit_buf) {
                                    let before = val.map(|v| format!("{v}")).unwrap_or_default();
                                    *act = Some((
                                        pi,
                                        v.to_le_bytes().to_vec(),
                                        before,
                                        format!("{v}"),
                                    ));
                                    self.objects.edit_pair = None;
                                }
                            }
                        } else {
                            // A reference shows as a hash, never as a float — and if we can say
                            // what it points at, that comes first.
                            let shown = match (val, is_ref) {
                                (Some(v), true) => format!("0x{v:08X}"),
                                (Some(v), false) => readable(v),
                                (None, _) => format!("<{} bytes>", p.data.len()),
                            };
                            if ui
                                .add(
                                    egui::Label::new(theme::data_text(shown, 11.5, theme::TX))
                                        .sense(egui::Sense::click()),
                                )
                                .on_hover_text("click to edit")
                                .clicked()
                            {
                                self.objects.edit_pair = Some(pi);
                                self.objects.edit_buf =
                                    val.map(|v| v.to_string()).unwrap_or_default();
                            }
                            if let Some((kind, label)) = &resolved {
                                ui.label(theme::disp_text(*kind, 9.0, theme::FAINT));
                                ui.label(theme::data_text(trunc(label, 34), 11.0, theme::COLD));
                            } else if is_ref {
                                ui.label(theme::data_text(
                                    "unresolved",
                                    10.0,
                                    theme::FAINT,
                                ))
                                .on_hover_text(
                                    "nothing loaded names this hash — load Strings and scan Icons to resolve it",
                                );
                            }
                        }
                        if let Some(c) = staged {
                            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                                ui.label(theme::data_text(
                                    format!("was {}", c.before),
                                    9.5,
                                    theme::COLD,
                                ));
                            });
                        }
                    }
                });

                // The four readings are for values whose TYPE is unknown. A named reference already
                // knows what it is, so showing four guesses there would be noise.
                if tex.is_none() && !is_ref {
                    if let Some(v) = val {
                        if !known {
                            four_readings(ui, v);
                        }
                    }
                }
            });
    }

    fn objects_context(&mut self, ui: &mut egui::Ui) {
        let sel = self.objects.selected;
        theme::card(ui, "Referenced by", None, |ui| {
            match sel {
                None => {
                    ui.label(theme::data_text("No template selected.", 10.5, theme::FAINT));
                }
                Some(i) => {
                    // who points at THIS template's name-hash
                    let nh = self.template_name(i).map(|n| pandemic_hash(&n));
                    let refs = nh.and_then(|h| self.xref.get(&h).cloned()).unwrap_or_default();
                    if refs.is_empty() {
                        ui.label(theme::data_text(
                            "Nothing else points at this template — changing it is contained.",
                            10.0,
                            theme::FAINT,
                        ));
                    } else {
                        ui.label(theme::data_text(
                            format!("{} template(s) reference it", refs.len()),
                            10.5,
                            theme::TX,
                        ));
                        for e in refs.iter().take(8) {
                            if let Some(n) = self.template_name(*e) {
                                ui.label(theme::data_text(n, 10.0, theme::DIM));
                            }
                        }
                    }
                }
            }
        });
    }

    // ============================================================== ICONS

    fn icons_nav(&mut self, ui: &mut egui::Ui) {
        theme::eyebrow(ui, "Texture pool");
        ui.add_space(3.0);
        ui.label(theme::data_text(
            "names are plaintext inside the pack; a template points at one by pandemic_hash(name)",
            10.0,
            theme::FAINT,
        ));
        ui.add_space(5.0);
        let prog = Some(self.icons.progress);
        if self.load_state(ui, "Palettes0.megapack", &self.icon_load, prog) {
            return;
        }
        ui.horizontal(|ui| {
            if theme::pill(ui, "referenced only", self.icons.only_used).clicked() {
                self.icons.only_used = !self.icons.only_used;
            }
        });
        ui.horizontal(|ui| {
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                if ui.button("✕").clicked() {
                    self.icons.search.clear();
                }
                ui.add_sized(
                    [ui.available_width(), 20.0],
                    egui::TextEdit::singleline(&mut self.icons.search).hint_text("filter name"),
                );
            });
        });
        let used = self.icon_recs().iter().filter(|(_, h, _, _, _)| self.xref.contains_key(h)).count();
        ui.label(theme::data_text(
            format!("{} records · {} referenced", self.icon_recs().len(), used),
            10.0,
            theme::FAINT,
        ));

        ui.add_space(10.0);
        theme::eyebrow(ui, "Reserve a name");
        ui.add_space(2.0);
        ui.label(theme::data_text(
            "a template can point at a texture before it exists — reserve the name, wire the hash, pack the DTEX with sab_dtex",
            10.0,
            theme::FAINT,
        ));
        ui.add_space(4.0);
        ui.add_sized(
            [ui.available_width(), 20.0],
            egui::TextEdit::singleline(&mut self.icons.new_name).hint_text("UI_Icon_MyThing_D"),
        );
        if !self.icons.new_name.is_empty() {
            let h = pandemic_hash(&self.icons.new_name);
            ui.label(theme::data_text(format!("→ 0x{h:08X}"), 10.5, theme::COLD));
            if theme::primary_button(ui, "Reserve", true).clicked() {
                let n = self.icons.new_name.clone();
                self.stage(
                    format!("+{n}"),
                    String::new(),
                    format!("0x{h:08X}"),
                    Op::ReserveTexture { name: n },
                );
                self.icons.new_name.clear();
            }
        }
    }

    fn icons_central(&mut self, ui: &mut egui::Ui) {
        if self.icon_load.ready().is_none() {
            self.empty_state(
                ui,
                "Icons",
                "Every texture in the pack, as pictures — because you pick an icon by looking at it.",
                &[
                    "A GameTemplate references a texture by pandemic_hash(name), so this page is also where you find the hash to wire into a property.",
                    "The pack is swept in the background as soon as the tool opens. Only the tiles you actually look at get decoded, and each takes the smallest mip that covers the tile.",
                ],
            );
            return;
        }
        if let Some((e, p)) = self.objects.wiring {
            egui::Frame::none()
                .fill(theme::RED_SOFT)
                .stroke(egui::Stroke::new(1.0, theme::RED_DK))
                .inner_margin(egui::Margin::symmetric(11.0, 8.0))
                .show(ui, |ui| {
                    ui.horizontal(|ui| {
                        ui.label(theme::disp_text("Wiring", 10.0, theme::RED));
                        let n = self.template_name(e).unwrap_or_default();
                        ui.label(theme::data_text(
                            format!("{n} · pair {p} — click a texture to bind it"),
                            11.0,
                            theme::TX,
                        ));
                        ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                            if ui.button("cancel").clicked() {
                                self.objects.wiring = None;
                            }
                        });
                    });
                });
            ui.add_space(8.0);
        }

        let needle = self.icons.search.to_ascii_lowercase();
        let rows: Vec<usize> = self
            .icon_recs()
            .iter()
            .enumerate()
            .filter(|(_, (n, h, _, _, _))| {
                (!self.icons.only_used || self.xref.contains_key(h))
                    && (needle.is_empty() || n.to_ascii_lowercase().contains(&needle))
            })
            .map(|(i, _)| i)
            .collect();

        ui.horizontal(|ui| {
            theme::chip(ui, &format!("{} shown", rows.len()), false, None);
            let used = rows.iter().filter(|i| self.xref.contains_key(&self.icon_recs()[**i].1)).count();
            theme::chip(ui, &format!("{used} referenced"), used > 0, None);
        });
        ui.add_space(8.0);

        // ---- the sheet ----
        //
        // Two things keep this from locking the window on a pool of a couple of thousand records:
        //
        // 1. VIRTUALISE. `show_rows` only runs the closure for rows actually on screen. A plain
        //    ScrollArea + Grid does not do this — it builds every child and merely clips the paint,
        //    which meant landing on this page decoded ~2,000 BC textures and uploaded them all to
        //    the GPU in ONE frame. That was the freeze.
        // 2. BUDGET. Even a screenful is ~40 decodes; a fast scroll would still hitch. So only a
        //    few new textures are decoded per frame and the rest arrive over the next few, with a
        //    repaint requested so they fill in promptly. Already-cached tiles never count.
        let tile = 152.0;
        let cap_h = 42.0;
        let row_h = 96.0 + cap_h + 8.0;
        let cols = ((ui.available_width() / (tile + 8.0)).floor() as usize).max(1);
        let n_rows = rows.len().div_ceil(cols);
        let mut clicked: Option<usize> = None;
        let mut waiting = false;

        egui::ScrollArea::vertical()
            .id_source("sheet")
            .auto_shrink([false, false])
            .show_rows(ui, row_h, n_rows, |ui, vis| {
                for r in vis {
                    ui.horizontal(|ui| {
                        for c in 0..cols {
                            let Some(&i) = rows.get(r * cols + c) else { break };
                            let (name, hash, ei, off, len) = self.icon_recs()[i].clone();
                            let is_used = self.xref.contains_key(&hash);
                            let sel = self.icons.selected == Some(i);
                            let tex = self.thumb(hash, ei, off, len);
                            if tex.is_none() {
                                waiting = true;
                            }
                            let resp = ui
                                .vertical(|ui| {
                                    ui.set_width(tile);
                                    match tex {
                                        Some(t) => {
                                            let mut img = egui::Image::new(&t)
                                                .fit_to_exact_size(egui::vec2(tile, 96.0));
                                            if !is_used {
                                                img = img.tint(egui::Color32::from_gray(110));
                                            }
                                            ui.add(img);
                                        }
                                        None => {
                                            let (rr, _) = ui.allocate_exact_size(
                                                egui::vec2(tile, 96.0),
                                                egui::Sense::hover(),
                                            );
                                            ui.painter().rect_filled(
                                                rr,
                                                egui::Rounding::ZERO,
                                                theme::G2,
                                            );
                                            ui.painter().text(
                                                rr.center(),
                                                egui::Align2::CENTER_CENTER,
                                                "·",
                                                egui::FontId::new(12.0, theme::data()),
                                                theme::FAINT,
                                            );
                                        }
                                    }
                                    ui.label(theme::data_text(
                                        trunc(&name, 18),
                                        10.5,
                                        if is_used { theme::TX } else { theme::DIM },
                                    ));
                                    ui.label(theme::data_text(
                                        format!("0x{hash:08X}"),
                                        10.0,
                                        if is_used { theme::EMBER } else { theme::FAINT },
                                    ));
                                })
                                .response;
                            let stroke = if sel {
                                egui::Stroke::new(1.0, theme::RED)
                            } else if is_used {
                                egui::Stroke::new(1.0, theme::EMBER_DK)
                            } else {
                                egui::Stroke::new(1.0, theme::LINE)
                            };
                            ui.painter().rect_stroke(resp.rect, egui::Rounding::ZERO, stroke);
                            if ui
                                .interact(resp.rect, ui.id().with(("tile", i)), egui::Sense::click())
                                .clicked()
                            {
                                clicked = Some(i);
                            }
                        }
                    });
                    ui.add_space(8.0);
                }
            });
        if waiting {
            // pixels are in flight; come back for them
            ui.ctx().request_repaint_after(std::time::Duration::from_millis(60));
        }

        if let Some(i) = clicked {
            self.icons.selected = Some(i);
            // if a property is waiting on a value, bind it and go back
            if let Some((e, p)) = self.objects.wiring.take() {
                let (name, hash, _, _, _) = self.icon_recs()[i].clone();
                let before = self
                    .obj_load
                    .ready()
                    .and_then(|g| match g.entries.get(e) {
                        Some(Entry::Template(t)) => t.pairs.get(p).and_then(|x| x.as_u32()),
                        _ => None,
                    })
                    .map(|v| {
                        self.icon_recs()
                            .iter()
                            .find(|(_, h, _, _, _)| *h == v)
                            .map(|(n, _, _, _, _)| n.clone())
                            .unwrap_or_else(|| format!("0x{v:08X}"))
                    })
                    .unwrap_or_default();
                let tname = self.template_name(e).unwrap_or_default();
                self.stage(
                    format!("{tname} · pair {p}"),
                    before,
                    name,
                    Op::SetPair { entry: e, pair: p, bytes: hash.to_le_bytes().to_vec() },
                );
            }
        }
    }

    fn icons_context(&mut self, ui: &mut egui::Ui) {
        let sel = self.icons.selected;
        theme::card(ui, "Selected", None, |ui| match sel {
            None => {
                ui.label(theme::data_text("No texture selected.", 10.5, theme::FAINT));
            }
            Some(i) => {
                let (name, hash, _, _, _) = self.icon_recs()[i].clone();
                ui.label(theme::data_text(&name, 11.0, theme::TX));
                ui.label(theme::data_text(format!("0x{hash:08X}"), 10.5, theme::COLD));
                ui.add_space(4.0);
                let refs = self.xref.get(&hash).cloned().unwrap_or_default();
                ui.label(theme::data_text(
                    format!("used by {} template(s)", refs.len()),
                    10.5,
                    if refs.is_empty() { theme::FAINT } else { theme::EMBER },
                ));
                for e in refs.iter().take(8) {
                    if let Some(n) = self.template_name(*e) {
                        ui.label(theme::data_text(n, 10.0, theme::DIM));
                    }
                }
                if refs.is_empty() {
                    ui.label(theme::data_text(
                        "nothing references it — safe to repurpose",
                        10.0,
                        theme::FAINT,
                    ));
                }
            }
        });
    }

    /// The texture for a record, or `None` while the worker is still on it. Never blocks: an
    /// un-cached tile fires one request and draws a placeholder until the pixels arrive.
    fn thumb(&mut self, hash: u32, ei: usize, off: usize, len: usize) -> Option<egui::TextureHandle> {
        if let Some(hit) = self.thumbs.cache.get(&hash) {
            return hit.clone();
        }
        if self.thumbs.pending.insert(hash) {
            if let Some(q) = &self.thumbs.req {
                let _ = q.send((hash, ei, off, len));
            }
        }
        None
    }

    // ------------------------------------------------------------------ shared

    /// A page with nothing loaded still has to teach: say what the page is for and what the format
    /// makes awkward, rather than showing an empty pane.
    fn empty_state(&self, ui: &mut egui::Ui, title: &str, sub: &str, notes: &[&str]) {
        ui.add_space(28.0);
        ui.label(theme::poster_text(title, 26.0, theme::TX));
        ui.add_space(4.0);
        ui.label(theme::data_text(sub, 12.0, theme::DIM));
        ui.add_space(14.0);
        // Bounded so long explanations wrap into a readable column instead of running off the panel.
        let wrap = ui.available_width().min(620.0);
        for n in notes {
            ui.horizontal_top(|ui| {
                ui.label(theme::data_text("·", 12.0, theme::RED));
                ui.add_space(4.0);
                ui.allocate_ui(egui::vec2(wrap, 0.0), |ui| {
                    ui.add(
                        egui::Label::new(egui::RichText::new(*n).size(11.5).color(theme::FAINT))
                            .wrap(),
                    );
                });
            });
            ui.add_space(7.0);
        }
    }
}

// ---------------------------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------------------------

/// One pass over every pair: any 4-byte value is a candidate hash, so index value → templates.
/// This is what lets the Icons page say "used by" and the Strings page recover a name.
fn build_xref(gt: &GameTemplates) -> std::collections::HashMap<u32, Vec<usize>> {
    let mut xref: std::collections::HashMap<u32, Vec<usize>> = Default::default();
    for (i, e) in gt.entries.iter().enumerate() {
        if let Entry::Template(t) = e {
            for p in &t.pairs {
                if let Some(v) = p.as_u32() {
                    let slot = xref.entry(v).or_default();
                    if !slot.contains(&i) {
                        slot.push(i);
                    }
                }
            }
        }
    }
    xref
}

fn trunc(s: &str, n: usize) -> String {
    match s.char_indices().nth(n) {
        Some((b, _)) => format!("{}…", &s[..b]),
        None => s.to_string(),
    }
}

/// The most plausible single-line form of a 4-byte value.
fn readable(v: u32) -> String {
    let f = f32::from_bits(v);
    if f.is_finite() && f != 0.0 && f.abs() >= 1e-3 && f.abs() < 1e7 {
        format!("{v}  ·  {f:.3}f")
    } else {
        format!("{v}")
    }
}

/// Show a value read every way at once, with the likeliest lit. Beats making the modder choose a
/// type from a radio before the UI will show them anything.
fn four_readings(ui: &mut egui::Ui, v: u32) {
    let f = f32::from_bits(v);
    let float_ok = f.is_finite() && f != 0.0 && f.abs() >= 1e-3 && f.abs() < 1e7;
    // A small int is a far more likely count than a denormal float.
    let int_ok = v < 100_000;
    let ascii: String = v
        .to_le_bytes()
        .iter()
        .map(|b| if b.is_ascii_graphic() { *b as char } else { '·' })
        .collect();
    let ascii_ok = v.to_le_bytes().iter().filter(|b| b.is_ascii_graphic()).count() >= 3;

    egui::Frame::none()
        .fill(theme::G0)
        .stroke(egui::Stroke::new(1.0, theme::LINE))
        .inner_margin(egui::Margin::symmetric(0.0, 0.0))
        .outer_margin(egui::Margin { top: 5.0, ..Default::default() })
        .show(ui, |ui| {
            ui.horizontal(|ui| {
                let cell = |ui: &mut egui::Ui, k: &str, val: String, lit: bool| {
                    egui::Frame::none()
                        .fill(if lit { theme::COLD_SOFT } else { egui::Color32::TRANSPARENT })
                        .inner_margin(egui::Margin::symmetric(8.0, 4.0))
                        .show(ui, |ui| {
                            ui.vertical(|ui| {
                                ui.label(theme::disp_text(
                                    k,
                                    9.0,
                                    if lit { theme::COLD } else { theme::FAINT },
                                ));
                                ui.label(theme::data_text(
                                    val,
                                    10.5,
                                    if lit { theme::TX } else { theme::DIM },
                                ));
                            });
                        });
                };
                cell(ui, "as int", format!("{v}"), int_ok && !float_ok);
                cell(
                    ui,
                    "as float",
                    if float_ok { format!("{f:.3}") } else { "—".into() },
                    float_ok,
                );
                cell(ui, "as hash", format!("0x{v:08X}"), false);
                cell(ui, "as ascii", ascii, ascii_ok);
            });
        });
}

/// Accept decimal, `0x…` hex, or a float — whichever the modder typed.
fn parse_u32_any(t: &str) -> Result<u32, String> {
    let t = t.trim();
    if let Some(h) = t.strip_prefix("0x").or_else(|| t.strip_prefix("0X")) {
        return u32::from_str_radix(h, 16).map_err(|e| e.to_string());
    }
    if let Ok(i) = t.parse::<i64>() {
        return Ok(i as u32);
    }
    if let Ok(f) = t.parse::<f32>() {
        return Ok(f.to_bits());
    }
    Err("not a number".into())
}
