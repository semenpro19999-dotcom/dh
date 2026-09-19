import { useEffect, useMemo, useState } from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'

const navGroups = [
  {
    label: 'OPERATIONS',
    items: [
      { id: 'overview', label: 'Overview', icon: 'grid' },
      { id: 'matchmaking', label: 'Matchmaking', icon: 'crosshair', badge: '2' },
      { id: 'loadout', label: 'Inventory', icon: 'briefcase' },
      { id: 'case-lab', label: 'Case Lab', icon: 'cube', badge: 'NEW' },
    ],
  },
  {
    label: 'INTEL',
    items: [
      { id: 'progression', label: 'Progression', icon: 'chart' },
      { id: 'training', label: 'Training', icon: 'target' },
      { id: 'field-hud', label: 'Field HUD', icon: 'crosshair' },
      { id: 'patch-notes', label: 'Patch notes', icon: 'file' },
    ],
  },
]

const items = [
  { name: 'FEN-9 // Cobalt Circuit', type: 'ASSAULT RIFLE', rarity: 'MYTHIC', image: '/assets/fen-9-cobalt.jpg', tone: 'blue', wear: '0.08' },
  { name: 'Vanta Edge // Null', type: 'MELEE', rarity: 'IMMORTAL', image: '/assets/vanta-edge.jpg', tone: 'purple', wear: '0.01' },
  { name: 'Kestrel // Field Issue', type: 'SMG', rarity: 'RARE', tone: 'amber', wear: '0.21' },
  { name: 'M-7 // Signal Burn', type: 'PISTOL', rarity: 'UNCOMMON', tone: 'green', wear: '0.33' },
  { name: 'Aegis // Cold Forge', type: 'GLOVES', rarity: 'MYTHIC', tone: 'cyan', wear: '0.12' },
  { name: 'Rook // Carbon', type: 'SHOTGUN', rarity: 'COMMON', tone: 'slate', wear: '0.48' },
]

const caseData = [
  { title: 'RIFT // AFTERGLOW', subtitle: 'SEASONAL CASE 03', count: '18 items', rarity: 'SEASONAL', tone: 'cyan', accent: '#56d6d1', image: '/assets/fen-9-cobalt.jpg' },
  { title: 'BLACKSITE // 01', subtitle: 'STANDARD CASE', count: '24 items', rarity: 'STANDARD', tone: 'purple', accent: '#a889e9', image: '/assets/vanta-edge.jpg' },
  { title: 'SIGNAL // GOLD', subtitle: 'EVENT CASE', count: '9 items', rarity: 'LIMITED', tone: 'amber', accent: '#f4b76b', image: '/assets/fen-9-cobalt.jpg' },
]

const rankSteps = [
  { name: 'VECTOR', level: 'I', color: 'slate', score: '0—1,199' },
  { name: 'VECTOR', level: 'II', color: 'slate', score: '1,200—1,499' },
  { name: 'VECTOR', level: 'III', color: 'cyan', score: '1,500—1,799' },
  { name: 'VECTOR', level: 'IV', color: 'cyan', score: '1,800—2,099' },
  { name: 'VECTOR', level: 'V', color: 'gold', score: '2,100—2,399' },
  { name: 'APEX', level: 'I', color: 'purple', score: '2,400+' },
]

function Icon({ name, size = 18, strokeWidth = 1.7 }) {
  const common = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth, strokeLinecap: 'round', strokeLinejoin: 'round', 'aria-hidden': true }
  const paths = {
    grid: <><rect x="3" y="3" width="7" height="7" rx="1" /><rect x="14" y="3" width="7" height="7" rx="1" /><rect x="3" y="14" width="7" height="7" rx="1" /><rect x="14" y="14" width="7" height="7" rx="1" /></>,
    crosshair: <><circle cx="12" cy="12" r="6.5" /><path d="M12 2v3M12 19v3M2 12h3M19 12h3" /><circle cx="12" cy="12" r="1" fill="currentColor" /></>,
    briefcase: <><rect x="3" y="7" width="18" height="13" rx="2" /><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M3 12h18M10 12v2h4v-2" /></>,
    cube: <><path d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" /><path d="m4.3 7.7 7.7 4.4 7.7-4.4M12 12.1V21" /></>,
    chart: <><path d="M4 19V5M4 19h17" /><path d="m7 15 4-4 3 2 5-6" /><path d="M17 7h2v2" /></>,
    target: <><circle cx="12" cy="12" r="8.5" /><circle cx="12" cy="12" r="4.5" /><circle cx="12" cy="12" r="1" fill="currentColor" /><path d="M12 2v2M22 12h-2M12 22v-2M2 12h2" /></>,
    file: <><path d="M6 3h8l4 4v14H6z" /><path d="M14 3v5h5M9 13h6M9 17h5" /></>,
    settings: <><path d="M12 3v2M12 19v2M3 12h2M19 12h2M5.6 5.6 7 7M17 17l1.4 1.4M18.4 5.6 17 7M7 17l-1.4 1.4" /><circle cx="12" cy="12" r="5" /></>,
    bell: <><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4" /></>,
    search: <><circle cx="10.5" cy="10.5" r="6.5" /><path d="m16 16 5 5" /></>,
    arrow: <><path d="M5 12h14M13 6l6 6-6 6" /></>,
    chevron: <path d="m9 18 6-6-6-6" />,
    plus: <><path d="M12 5v14M5 12h14" /></>,
    play: <path d="m9 5 10 7-10 7V5Z" fill="currentColor" stroke="none" />,
    lock: <><rect x="5" y="10" width="14" height="11" rx="2" /><path d="M8 10V7a4 4 0 0 1 8 0v3" /></>,
    globe: <><circle cx="12" cy="12" r="9" /><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18" /></>,
    users: <><path d="M16 20v-1.5a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4V20M9.5 10.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7ZM16 3.8a3.5 3.5 0 0 1 0 6.8M21 20v-1.5a4 4 0 0 0-3-3.8" /></>,
    wallet: <><path d="M4 6.5A2.5 2.5 0 0 1 6.5 4H20v16H6.5A2.5 2.5 0 0 1 4 17.5v-11Z" /><path d="M4 7h16M16 12h4" /><circle cx="16" cy="12" r=".5" fill="currentColor" /></>,
    expand: <><path d="M8 3H3v5M16 3h5v5M8 21H3v-5M21 16v5h-5" /><path d="m3 3 6 6M21 3l-6 6M3 21l6-6M21 21l-6-6" /></>,
    close: <><path d="m6 6 12 12M18 6 6 18" /></>,
    check: <path d="m5 12 4 4L19 6" />,
    dots: <><circle cx="5" cy="12" r="1" fill="currentColor" stroke="none" /><circle cx="12" cy="12" r="1" fill="currentColor" stroke="none" /><circle cx="19" cy="12" r="1" fill="currentColor" stroke="none" /></>,
    star: <path d="m12 3 2.8 5.8 6.2.9-4.5 4.5 1 6.3-5.5-3-5.5 3 1-6.3L3 9.7l6.2-.9L12 3Z" />,
    shield: <path d="M12 3 20 6v5c0 5-3.4 8.6-8 10-4.6-1.4-8-5-8-10V6l8-3Z" />,
    headset: <><path d="M4 14v-2a8 8 0 0 1 16 0v2" /><path d="M4 14h3v5H5a1 1 0 0 1-1-1v-4ZM20 14h-3v5h2a1 1 0 0 0 1-1v-4Z" /></>,
    refresh: <><path d="M20 11a8 8 0 0 0-14.7-4L3 10" /><path d="M3 5v5h5M4 13a8 8 0 0 0 14.7 4L21 14" /><path d="M21 19v-5h-5" /></>,
  }
  return <svg {...common}>{paths[name] || paths.grid}</svg>
}

function Avatar({ variant = 1, size = 'md' }) {
  return <span className={`avatar avatar-${variant} avatar-${size}`} aria-label="operator avatar"><span /></span>
}

function SectionHeader({ eyebrow, title, action, onAction }) {
  return <div className="section-head">
    <div><div className="eyebrow">{eyebrow}</div><h2>{title}</h2></div>
    {action && <button className="text-button" onClick={onAction}>{action}<Icon name="arrow" size={15} /></button>}
  </div>
}

function App() {
  const [page, setPage] = useState('overview')
  const [settingsOpen, setSettingsOpen] = useState(false)
  const [profileOpen, setProfileOpen] = useState(false)
  const [toast, setToast] = useState(null)

  const pageTitle = useMemo(() => {
    const match = navGroups.flatMap((group) => group.items).find((item) => item.id === page)
    return match?.label || (page === 'profile' ? 'Operator profile' : 'Overview')
  }, [page])

  const showToast = (message, type = 'default') => {
    setToast({ message, type })
    window.clearTimeout(window.__ks3Toast)
    window.__ks3Toast = window.setTimeout(() => setToast(null), 3200)
  }

  const openPage = (nextPage) => {
    setPage(nextPage)
    setProfileOpen(false)
  }

  return <div className="app-shell">
    <Sidebar page={page} onNavigate={openPage} onSettings={() => setSettingsOpen(true)} />
    <main className="main-shell">
      <Topbar title={pageTitle} onSettings={() => setSettingsOpen(true)} onProfile={() => setProfileOpen(true)} />
      <div className="page-content">
        {page === 'overview' && <Overview onNavigate={openPage} onToast={showToast} />}
        {page === 'matchmaking' && <Matchmaking onToast={showToast} />}
        {page === 'loadout' && <Loadout onToast={showToast} />}
        {page === 'case-lab' && <CaseLab onToast={showToast} />}
        {page === 'progression' && <Progression onNavigate={openPage} />}
        {page === 'training' && <Training onToast={showToast} />}
        {page === 'field-hud' && <FieldHud onToast={showToast} />}
        {page === 'patch-notes' && <PatchNotes />}
        {page === 'profile' && <Profile onNavigate={openPage} onToast={showToast} />}
      </div>
    </main>
    {settingsOpen && <SettingsModal onClose={() => setSettingsOpen(false)} onToast={showToast} />}
    {profileOpen && <ProfileDrawer onClose={() => setProfileOpen(false)} onNavigate={openPage} />}
    {toast && <div className={`toast toast-${toast.type}`}><span className="toast-dot" />{toast.message}</div>}
  </div>
}

function Sidebar({ page, onNavigate, onSettings }) {
  return <aside className="sidebar">
    <div className="brand-lockup" onClick={() => onNavigate('overview')} role="button" tabIndex={0}>
      <div className="brand-mark"><span>K</span><i>S</i><b>3</b></div>
      <div><div className="brand-name">KS<span>3</span></div><div className="brand-meta">COMMAND CENTER</div></div>
    </div>
    <div className="system-status"><span className="status-pulse" />NETWORK ONLINE <span className="status-version">0.9.4</span></div>
    <nav className="sidebar-nav">
      {navGroups.map((group) => <div className="nav-group" key={group.label}>
        <div className="nav-label">{group.label}</div>
        {group.items.map((item) => <button key={item.id} className={`nav-item ${page === item.id ? 'is-active' : ''}`} onClick={() => onNavigate(item.id)}>
          <span className="nav-icon"><Icon name={item.icon} size={17} /></span><span>{item.label}</span>
          {item.badge && <span className={`nav-badge ${item.badge === 'NEW' ? 'badge-new' : ''}`}>{item.badge}</span>}
        </button>)}
      </div>)}
    </nav>
    <div className="sidebar-spacer" />
    <div className="season-card">
      <div className="season-orbit orbit-one" /><div className="season-orbit orbit-two" />
      <div className="season-top"><span>SEASON 03</span><span className="season-live">LIVE</span></div>
      <strong>RIFT<br />PROTOCOL</strong>
      <div className="season-progress"><span style={{ width: '68%' }} /></div>
      <div className="season-foot"><span>68% complete</span><span>24d 08h</span></div>
    </div>
    <button className="settings-link" onClick={onSettings}><Icon name="settings" size={17} />Settings <span className="shortcut">⌘ ,</span></button>
    <div className="sidebar-profile" onClick={() => onNavigate('profile')} role="button" tabIndex={0}>
      <Avatar variant={2} size="sm" /><div className="sidebar-profile-copy"><strong>niko//zero</strong><span><i /> ONLINE</span></div><Icon name="dots" size={15} />
    </div>
  </aside>
}

function Topbar({ title, onSettings, onProfile }) {
  return <header className="topbar">
    <div className="breadcrumb"><span>COMMAND CENTER</span><b>/</b><strong>{title.toUpperCase()}</strong></div>
    <div className="topbar-actions">
      <div className="region-pill"><span className="region-signal" /><span>EU NORTH</span><b>32 ms</b></div>
      <button className="top-icon" aria-label="notifications"><Icon name="bell" size={17} /><i /></button>
      <button className="top-icon" aria-label="settings" onClick={onSettings}><Icon name="settings" size={17} /></button>
      <div className="top-profile" onClick={onProfile} role="button" tabIndex={0}><Avatar variant={2} size="xs" /><div><strong>niko//zero</strong><span>RATING 2,480</span></div><Icon name="chevron" size={14} /></div>
    </div>
  </header>
}

function Overview({ onNavigate, onToast }) {
  return <>
    <section className="hero-panel">
      <div className="hero-image" />
      <div className="hero-grid" />
      <div className="hero-content">
        <div className="hero-kicker"><span className="kicker-line" />SEASON 03 <b>//</b> RIFT PROTOCOL</div>
        <h1>Precision<br /><em>over force.</em></h1>
        <p>Read the room. Break the line. Every round is a system waiting to be solved.</p>
        <div className="hero-actions"><button className="primary-button" onClick={() => onNavigate('matchmaking')}><Icon name="play" size={14} />FIND A MATCH</button><button className="ghost-button" onClick={() => onNavigate('training')}>VIEW OPERATIONS <Icon name="arrow" size={14} /></button></div>
      </div>
      <div className="hero-side-meta"><span>LIVE BUILD</span><strong>0.9.4</strong><div className="vertical-rule" /><span>RIFT / FALL</span></div>
      <div className="hero-bottom">
        <div className="hero-stat"><span>ACTIVE OPERATORS</span><strong>18,642</strong><i>+8.4%</i></div>
        <div className="hero-stat"><span>YOUR STREAK</span><strong>04 <small>WINS</small></strong><i className="muted">BEST 07</i></div>
        <div className="hero-stat"><span>SEASON RANK</span><strong>VECTOR <small>IV</small></strong><i>+124 RP</i></div>
        <div className="hero-scan"><span className="scan-dot" />SYNCED TO EU NORTH <Icon name="arrow" size={13} /></div>
      </div>
    </section>

    <div className="dashboard-grid top-cards">
      <QueueCard onNavigate={onNavigate} />
      <RankCard onNavigate={onNavigate} />
    </div>

    <div className="section-divider"><span>OPERATIONS FEED</span><i /><span>LAST SYNC 14:32:08 UTC</span></div>
    <section className="dashboard-grid feed-grid">
      <div className="panel intel-panel">
        <SectionHeader eyebrow="FIELD INTEL // 01" title="Active operations" action="VIEW ALL" onAction={() => onNavigate('patch-notes')} />
        <div className="operation-list">
          <OperationRow index="01" title="Controlled demolition" copy="Win a round after destroying 2 reinforced panels." reward="+2,500 XP" progress="72%" tone="cyan" />
          <OperationRow index="02" title="Quiet entry" copy="Plant the spike without triggering a sound cue." reward="+1,200 XP" progress="38%" tone="amber" />
          <OperationRow index="03" title="Weather the storm" copy="Complete 3 matches during a live weather event." reward="RIFT CASE" progress="0%" tone="purple" locked />
        </div>
      </div>
      <div className="panel squad-panel">
        <div className="squad-glow" />
        <SectionHeader eyebrow="SQUAD // 05" title="Your fireteam" action="INVITE" onAction={() => onToast('Invite link copied to clipboard', 'success')} />
        <div className="squad-list">
          <SquadRow avatar={2} name="niko//zero" role="SHOTCALLER" status="IN MENU" self />
          <SquadRow avatar={4} name="mara.v" role="ENTRY" status="IN MATCH" />
          <SquadRow avatar={1} name="k0met" role="ANCHOR" status="IN MENU" />
          <SquadRow avatar={3} name="sable_06" role="FLEX" status="AWAY" muted />
        </div>
        <button className="squad-add" onClick={() => onToast('Friend list opened', 'default')}><Icon name="plus" size={15} /> ADD OPERATOR <span>3 ONLINE</span></button>
      </div>
    </section>
  </>
}

function QueueCard({ onNavigate }) {
  return <div className="panel queue-card">
    <div className="queue-art"><div className="radar-ring ring-a" /><div className="radar-ring ring-b" /><div className="radar-sweep" /><span className="radar-blip blip-a" /><span className="radar-blip blip-b" /><span className="radar-blip blip-c" /></div>
    <div className="queue-content">
      <div className="eyebrow">READY WHEN YOU ARE</div><h3>Ranked <span>5v5</span></h3><p>Competitive ruleset · first to 13 · overtime enabled</p>
      <div className="queue-details"><div><span>MAP POOL</span><strong>RIFT / FALL <i>⌄</i></strong></div><div><span>QUEUE ETA</span><strong>00:43 <small>EST.</small></strong></div></div>
      <button className="wide-button" onClick={() => onNavigate('matchmaking')}>OPEN MATCHMAKING <Icon name="arrow" size={14} /></button>
    </div>
  </div>
}

function RankCard({ onNavigate }) {
  return <div className="panel rank-card">
    <div className="rank-card-head"><div><div className="eyebrow">YOUR SIGNAL</div><h3>VECTOR <span>IV</span></h3></div><div className="rank-emblem"><div className="emblem-core">V</div><span>2,480</span></div></div>
    <div className="rank-progress-label"><span>NEXT: VECTOR V</span><b>183 RP TO GO</b></div><div className="rank-progress"><span style={{ width: '62%' }} /><i /></div>
    <div className="rank-stats"><div><strong>14</strong><span>WINS</span></div><div><strong>09</strong><span>LOSSES</span></div><div><strong>1.18</strong><span>K/D</span></div><div><strong>63%</strong><span>HS RATE</span></div></div>
    <button className="text-button rank-link" onClick={() => onNavigate('progression')}>RANK HISTORY <Icon name="arrow" size={14} /></button>
  </div>
}

function OperationRow({ index, title, copy, reward, progress, tone, locked }) {
  return <div className={`operation-row ${locked ? 'is-locked' : ''}`}>
    <div className={`op-index tone-${tone}`}>{locked ? <Icon name="lock" size={13} /> : index}</div><div className="op-copy"><strong>{title}</strong><span>{copy}</span><div className="op-bar"><i className={`bar-${tone}`} style={{ width: progress }} /></div></div><div className="op-reward"><span>REWARD</span><b>{reward}</b></div><Icon name="chevron" size={14} />
  </div>
}

function SquadRow({ avatar, name, role, status, self, muted }) {
  return <div className={`squad-row ${muted ? 'is-muted' : ''}`}><Avatar variant={avatar} size="sm" /><div className="squad-name"><strong>{name}{self && <em>YOU</em>}</strong><span>{role}</span></div><div className={`squad-status ${status === 'IN MATCH' ? 'in-match' : ''}`}><i />{status}</div><Icon name="dots" size={14} /></div>
}

function Matchmaking({ onToast }) {
  const [mode, setMode] = useState('RANKED 5V5')
  const [searching, setSearching] = useState(false)
  const [elapsed, setElapsed] = useState(0)
  const [summary, setSummary] = useState(false)
  useEffect(() => {
    if (!searching) return undefined
    const timer = window.setInterval(() => setElapsed((value) => value + 1), 1000)
    return () => window.clearInterval(timer)
  }, [searching])
  const time = `${String(Math.floor(elapsed / 60)).padStart(2, '0')}:${String(elapsed % 60).padStart(2, '0')}`
  const toggleSearch = () => { setSearching((value) => !value); if (!searching) onToast('Search party assembled — scanning EU North', 'success'); else onToast('Matchmaking search cancelled', 'default') }
  return <>
    <div className="page-heading"><div><div className="eyebrow">OPERATIONS // MATCHMAKING</div><h1>Find your line.</h1><p>Choose a ruleset, lock your region, and let the system do the rest.</p></div><div className="heading-status"><span className="status-pulse" />EU NORTH <b>32 ms</b></div></div>
    <div className="mode-tabs">{['RANKED 5V5', 'CASUAL', 'WINGMAN', 'CUSTOM LOBBY'].map((item) => <button className={mode === item ? 'is-active' : ''} key={item} onClick={() => setMode(item)}>{item}{item === 'RANKED 5V5' && <span>RECOMMENDED</span>}</button>)}</div>
    <section className="match-grid">
      <div className="panel search-panel">
        <div className="search-panel-top"><div><div className="eyebrow">SELECTED QUEUE</div><h2>{mode}</h2></div><div className={`search-orb ${searching ? 'is-searching' : ''}`}><span /><i /><b>{searching ? time : 'READY'}</b></div></div>
        <div className="search-rule" />
        <div className="match-options"><OptionRow label="Map pool" value="RIFT / FALL + 4 MAPS" icon="globe" /><OptionRow label="Party size" value="SOLO / DUO / FULL STACK" icon="users" /><OptionRow label="Server region" value="EU NORTH · 32 ms" icon="crosshair" /></div>
        <div className="search-footer"><div className="estimated"><span>ESTIMATED WAIT</span><strong>00:43</strong><small>Based on 18,642 active operators</small></div><button className={`primary-button queue-button ${searching ? 'is-cancel' : ''}`} onClick={toggleSearch}><Icon name={searching ? 'close' : 'play'} size={14} />{searching ? 'CANCEL SEARCH' : 'START SEARCH'}</button></div>
        <button className="demo-match" onClick={() => setSummary(true)}><Icon name="refresh" size={13} /> PREVIEW POST-MATCH SCREEN</button>
      </div>
      <div className="panel map-preview">
        <div className="map-image"><div className="map-overlay-grid" /><div className="map-label label-a">A</div><div className="map-label label-b">B</div><div className="map-route route-one" /><div className="map-route route-two" /><div className="map-marker marker-one" /><div className="map-marker marker-two" /></div>
        <div className="map-copy"><div><div className="eyebrow">CURRENT MAP // 01</div><h3>RIFT / FALL</h3><p>Port Helix · Mediterranean Exclusion Zone</p></div><span className="map-type">DE_5V5</span></div>
        <div className="map-tags"><span>WEATHER: OVERCAST</span><span>BREAKABLES: ACTIVE</span><span>ROTATION: 02:14:08</span></div>
      </div>
    </section>
    <section className="panel map-pool-panel"><SectionHeader eyebrow="MAP POOL // 05" title="Know the ground" action="MAP GUIDE" /><div className="mini-maps"><MiniMap name="RIFT / FALL" loc="PORT HELIX" active tone="cyan" /><MiniMap name="VANTA LINE" loc="METRO DISTRICT" tone="purple" /><MiniMap name="CINDER YARD" loc="FREIGHT TERMINAL" tone="amber" /><MiniMap name="ORBITAL" loc="RESEARCH CAMPUS" tone="green" /><MiniMap name="SALTWORKS" loc="DESALINATION PLANT" tone="slate" /></div></section>
    {summary && <MatchSummary onClose={() => setSummary(false)} />}
  </>
}

function OptionRow({ label, value, icon }) {
  return <div className="option-row"><span className="option-icon"><Icon name={icon} size={16} /></span><div><span>{label}</span><strong>{value}</strong></div><Icon name="chevron" size={14} /></div>
}

function MiniMap({ name, loc, active, tone }) {
  return <div className={`mini-map ${active ? 'active' : ''}`}><div className={`mini-map-art map-${tone}`}><i /><b /><span /></div><div><strong>{name}</strong><span>{loc}</span></div>{active && <em>LIVE</em>}</div>
}

function MatchSummary({ onClose }) {
  return <div className="modal-backdrop"><div className="match-summary modal-card">
    <button className="modal-close" onClick={onClose}><Icon name="close" size={17} /></button><div className="summary-banner"><span>RANKED // MATCH COMPLETE</span><strong>VICTORY</strong><small>RIFT / FALL · 36:42</small></div>
    <div className="summary-result"><div className="result-score"><strong>13</strong><span>—</span><strong className="loss">09</strong></div><div><span>YOU FINISHED</span><b>MVP · #01</b></div><div className="rp-gain"><span>RATING CHANGE</span><b>+124 RP</b></div></div>
    <div className="summary-table"><div className="table-head"><span>OPERATOR</span><span>K / D / A</span><span>IMPACT</span><span>RATING</span></div>{[['niko//zero','27 / 14 / 8','1,642','+124'],['mara.v','21 / 16 / 5','1,308','+98'],['k0met','18 / 17 / 11','1,192','+72'],['sable_06','16 / 18 / 9','1,018','+46']].map((row, i) => <div className={`table-row ${i === 0 ? 'mvp-row' : ''}`} key={row[0]}><div><Avatar variant={i + 1} size="xs" /><b>{row[0]}</b>{i === 0 && <em>MVP</em>}</div><span>{row[1]}</span><span>{row[2]}</span><strong>{row[3]}</strong></div>)}</div>
    <div className="summary-footer"><div><span>BATTLEPASS XP</span><strong>+3,840</strong></div><div><span>ITEM DROP</span><strong>RIFT // AFTERGLOW CASE</strong></div><button className="primary-button" onClick={onClose}>RETURN TO MENU</button></div>
  </div></div>
}

function Loadout({ onToast }) {
  const [filter, setFilter] = useState('ALL ITEMS')
  const filters = ['ALL ITEMS', 'WEAPONS', 'MELEE', 'GLOVES', 'STICKERS']
  const filtered = filter === 'ALL ITEMS' ? items : items.filter((item) => item.type.includes(filter.slice(0, -1)) || (filter === 'WEAPONS' && !['MELEE', 'GLOVES'].includes(item.type)))
  return <>
    <div className="page-heading"><div><div className="eyebrow">ARMORY // COLLECTION</div><h1>Inventory.</h1><p>Every item tells a story. Yours is still being written.</p></div><div className="credits"><Icon name="wallet" size={16} /><strong>12,840</strong><span>KS3 CREDITS</span><button onClick={() => onToast('Store opened', 'default')}><Icon name="plus" size={14} /></button></div></div>
    <div className="inventory-banner"><div><div className="eyebrow">EQUIPPED LOADOUT // RANKED</div><h2>FEN-9 <em>COBALT CIRCUIT</em></h2><p>Assault rifle · Mythic · Wear 0.08</p><button className="ghost-button" onClick={() => onToast('Inspect mode enabled', 'success')}>INSPECT IN 3D <Icon name="expand" size={14} /></button></div><div className="loadout-weapon"><img src="/assets/fen-9-cobalt.jpg" alt="FEN-9 Cobalt Circuit" /><span className="weapon-badge">MYTHIC</span></div><div className="inventory-stat"><span>COLLECTION VALUE</span><strong>₭ 84,920</strong><small>+ 6.2% THIS SEASON</small></div></div>
    <div className="inventory-toolbar"><div className="filter-tabs">{filters.map((item) => <button key={item} className={filter === item ? 'is-active' : ''} onClick={() => setFilter(item)}>{item}<span>{item === 'ALL ITEMS' ? 24 : item === 'WEAPONS' ? 15 : item === 'MELEE' ? 3 : item === 'GLOVES' ? 2 : 4}</span></button>)}</div><button className="sort-button"><Icon name="chart" size={14} /> SORT: RARITY <Icon name="chevron" size={13} /></button></div>
    <div className="inventory-grid">{filtered.map((item) => <InventoryCard item={item} key={item.name} onToast={onToast} />)}<div className="empty-slot"><Icon name="plus" size={18} /><span>ADD ITEM</span></div><div className="empty-slot"><Icon name="plus" size={18} /><span>ADD ITEM</span></div></div>
  </>
}

function InventoryCard({ item, onToast }) {
  return <article className={`inventory-card rarity-${item.tone}`} onClick={() => onToast(`${item.name} equipped to inspection slot`, 'success')}>
    <div className="item-top"><span>{item.type}</span><b>{item.rarity}</b></div><div className="item-art">{item.image ? <img src={item.image} alt="" /> : <WeaponSilhouette tone={item.tone} />}</div><div className="item-bottom"><div><strong>{item.name.split(' // ')[0]}</strong><span>{item.name.split(' // ')[1]}</span></div><div className="wear"><span>WEAR</span><b>{item.wear}</b></div></div><div className="rarity-line" /></article>
}

function WeaponSilhouette({ tone }) {
  return <div className={`weapon-silhouette silhouette-${tone}`}><span /><i /><b /></div>
}

function CaseLab({ onToast }) {
  const [opening, setOpening] = useState(null)
  return <>
    <div className="page-heading case-heading"><div><div className="eyebrow">DROP SYSTEM // SEASON 03</div><h1>Case lab.</h1><p>Open the signal. Chase the improbable.</p></div><div className="case-balance"><span>CASE TOKENS</span><strong>08</strong><button onClick={() => onToast('Token shop opened', 'default')}><Icon name="plus" size={14} /></button></div></div>
    <section className="featured-case panel"><div className="featured-copy"><div className="case-stamp">LIMITED RUN <span>03—24</span></div><div className="eyebrow">FEATURED CASE // RIFT PROTOCOL</div><h2>Afterglow<br /><em>Collection.</em></h2><p>A curated drop of hard light, soft metals and objects built for the last round of the night.</p><div className="featured-meta"><span><b>18</b> ITEMS</span><span><b>1</b> IMMORTAL</span><span><b>02d 14h</b> LEFT</span></div><button className="primary-button" onClick={() => setOpening(caseData[0])}>OPEN CASE <Icon name="arrow" size={14} /></button></div><div className="featured-art"><div className="case-ring ring-one" /><div className="case-ring ring-two" /><div className="featured-card-object"><img src="/assets/fen-9-cobalt.jpg" alt="Afterglow collection weapon" /><span>FEN-9</span></div><span className="featured-side-label">AFTER<br />GLOW</span></div></section>
    <SectionHeader eyebrow="THE DROP ROOM" title="Available cases" />
    <div className="case-grid">{caseData.map((item) => <CaseCard key={item.title} item={item} onOpen={() => setOpening(item)} />)}</div>
    <section className="drop-info-grid"><div className="panel drop-table"><SectionHeader eyebrow="ODDS // TRANSPARENCY" title="Signal distribution" /><DropRow label="COMMON" chance="78.00%" color="slate" /><DropRow label="UNCOMMON" chance="16.00%" color="green" /><DropRow label="RARE" chance="5.00%" color="blue" /><DropRow label="MYTHIC" chance="0.90%" color="purple" /><DropRow label="LEGENDARY" chance="0.09%" color="gold" /><DropRow label="IMMORTAL" chance="0.01%" color="red" /></div><div className="panel pity-card"><div className="eyebrow">PITY PROTOCOL</div><div className="pity-orbit"><span>07</span><small>OPENINGS</small></div><h3>One signal<br /><em>always returns.</em></h3><p>After 10 openings without Mythic or above, your next roll is guaranteed to upgrade.</p><button className="text-button" onClick={() => onToast('Pity protocol details opened', 'default')}>READ THE RULES <Icon name="arrow" size={14} /></button></div></section>
    {opening && <CaseOpeningModal item={opening} onClose={() => setOpening(null)} onToast={onToast} />}
  </>
}

function CaseCard({ item, onOpen }) {
  return <article className={`case-card case-${item.tone}`} onClick={onOpen}><div className="case-card-art"><img src={item.image} alt="" /><div className="case-card-halo" /><span>{item.rarity}</span></div><div className="case-card-copy"><div><strong>{item.title}</strong><span>{item.subtitle}</span></div><b>{item.count}</b></div><button className="case-open-link">OPEN <Icon name="arrow" size={13} /></button></article>
}

function DropRow({ label, chance, color }) {
  return <div className="drop-row"><span className={`drop-dot dot-${color}`} /><strong>{label}</strong><i /><b>{chance}</b></div>
}

function CaseOpeningModal({ item, onClose, onToast }) {
  const [rolling, setRolling] = useState(false)
  const [won, setWon] = useState(null)
  const start = () => {
    setRolling(true); setWon(null)
    window.setTimeout(() => { setRolling(false); setWon({ name: 'Vanta Edge', skin: 'Null / IMMORTAL', image: '/assets/vanta-edge.jpg' }); onToast('Immortal item acquired — added to inventory', 'success') }, 2800)
  }
  return <div className="modal-backdrop"><div className={`case-modal modal-card ${rolling ? 'is-rolling' : ''}`}>
    <button className="modal-close" onClick={onClose}><Icon name="close" size={17} /></button>
    {!won ? <><div className="case-modal-head"><div className="eyebrow">{item.subtitle}</div><h2>{item.title}</h2><p>One opening · transparent odds · no duplicates</p></div><div className="roulette"><div className="roulette-line" /><div className="roulette-track">{Array.from({ length: 11 }).map((_, i) => <div className={`roulette-item roulette-${i % 4}`} key={i}>{i === 5 ? <img src="/assets/vanta-edge.jpg" alt="" /> : <WeaponSilhouette tone={['slate', 'blue', 'amber', 'purple'][i % 4]} />}<span>{['Rook', 'Kestrel', 'Signal', 'Vanta'][i % 4]}</span></div>)}</div><div className="roulette-fade left" /><div className="roulette-fade right" /></div><div className="case-modal-foot"><span>CASE TOKEN <b>08</b></span><button className="primary-button" onClick={start} disabled={rolling}>{rolling ? 'SCANNING SIGNAL…' : 'OPEN FOR 1 TOKEN'} <Icon name="arrow" size={14} /></button></div></> : <div className="won-state"><div className="won-label"><Icon name="star" size={14} /> SIGNAL ACQUIRED <Icon name="star" size={14} /></div><div className="won-art"><img src={won.image} alt="" /><div className="won-burst" /></div><div className="eyebrow">IMMORTAL // MELEE</div><h2>{won.name}</h2><p>{won.skin}</p><div className="won-actions"><button className="ghost-button" onClick={onClose}>CLOSE</button><button className="primary-button" onClick={() => { onClose(); onToast('Vanta Edge equipped', 'success') }}>EQUIP ITEM <Icon name="arrow" size={14} /></button></div></div>}
  </div></div>
}

function Progression({ onNavigate }) {
  return <>
    <div className="page-heading"><div><div className="eyebrow">COMPETITIVE // SEASON 03</div><h1>Read the signal.</h1><p>Your rank is a reflection of decisions, not just aim.</p></div><div className="season-count"><span>SEASON ENDS IN</span><strong>24<span>d</span> 08<span>h</span> 14<span>m</span></strong></div></div>
    <section className="rank-hero panel"><div className="rank-hero-copy"><div className="eyebrow">CURRENT SIGNAL</div><div className="big-rank">VECTOR <em>IV</em></div><div className="rating-line"><strong>2,480</strong><span>RATING</span><i>+124 THIS WEEK</i></div><div className="large-rank-progress"><span style={{ width: '62%' }} /><b>183 RP</b></div><p>One clean win puts you on the doorstep of Vector V. Keep the line quiet.</p><button className="primary-button" onClick={() => onNavigate('matchmaking')}>QUEUE RANKED <Icon name="arrow" size={14} /></button></div><div className="rank-hero-emblem"><div className="emblem-large"><span>V</span><i /></div><div className="emblem-label">VECTOR // IV</div></div><div className="rank-streak"><span>FORM // LAST 10</span><div>{['W','W','L','W','W','W','L','W','W','W'].map((v, i) => <i className={v === 'W' ? 'win' : 'loss'} key={i}>{v}</i>)}</div><small>8 WINS · 2 LOSSES</small></div></section>
    <section className="rank-ladder panel"><SectionHeader eyebrow="RANK LADDER // 06" title="The climb" action="RANK RULES" /><div className="ladder-line"><span /></div><div className="ladder-steps">{rankSteps.map((step, i) => <div className={`ladder-step ${i === 3 ? 'current' : ''} ${i < 3 ? 'passed' : ''}`} key={`${step.name}${step.level}`}><div className={`ladder-node node-${step.color}`}>{i < 3 ? <Icon name="check" size={15} /> : <span>{step.level}</span>}</div><strong>{step.name} <em>{step.level}</em></strong><span>{step.score}</span>{i === 3 && <b>CURRENT</b>}</div>)}</div></section>
    <div className="stats-and-rewards"><section className="panel performance-panel"><SectionHeader eyebrow="PERFORMANCE // 30 DAYS" title="Signal quality" /><div className="performance-chart"><div className="chart-y"><span>100</span><span>75</span><span>50</span><span>25</span><span>0</span></div><div className="chart-field"><div className="chart-grid-lines" /><svg viewBox="0 0 600 160" preserveAspectRatio="none"><defs><linearGradient id="chartFill" x1="0" x2="0" y1="0" y2="1"><stop offset="0" stopColor="#73ddd7" stopOpacity=".25" /><stop offset="1" stopColor="#73ddd7" stopOpacity="0" /></linearGradient></defs><path d="M0 118 C25 112 36 126 60 107 S98 100 118 115 S148 108 170 95 S205 102 224 77 S255 82 280 68 S314 84 337 60 S367 68 390 50 S420 69 448 46 S480 58 505 38 S545 51 600 22 V160 H0Z" fill="url(#chartFill)" /><path d="M0 118 C25 112 36 126 60 107 S98 100 118 115 S148 108 170 95 S205 102 224 77 S255 82 280 68 S314 84 337 60 S367 68 390 50 S420 69 448 46 S480 58 505 38 S545 51 600 22" fill="none" stroke="#73ddd7" strokeWidth="2" /></svg><div className="chart-tooltip"><strong>2,480</strong><span>SEP 19</span></div></div></div><div className="chart-legend"><span><i />RATING</span><b>+18.4% <small>vs last month</small></b></div></section><section className="panel rewards-panel"><SectionHeader eyebrow="SEASON TRACK" title="Next unlocks" action="OPEN TRACK" /><div className="reward-row"><div className="reward-icon reward-case"><Icon name="cube" size={19} /></div><div><strong>Rift // Afterglow Case</strong><span>Level 42 · 1,240 XP away</span></div><b>42</b></div><div className="reward-row"><div className="reward-icon reward-credit"><Icon name="wallet" size={19} /></div><div><strong>1,500 KS3 Credits</strong><span>Level 45 · 3,840 XP away</span></div><b>45</b></div><div className="reward-row locked-reward"><div className="reward-icon reward-skin"><Icon name="lock" size={18} /></div><div><strong>Vanta Edge // Null</strong><span>Level 50 · Mythic reward</span></div><b>50</b></div></section></div>
  </>
}

function Training({ onToast }) {
  const drills = [
    { index: '01', title: 'Signal Sense', copy: 'Learn to read the first 3 seconds of a round. Audio, weather and timing.', tags: ['AUDIO', 'DECISIONS'], tone: 'cyan', progress: '68%', icon: 'headset' },
    { index: '02', title: 'Recoil Lab', copy: 'Build muscle memory against every KS3 weapon with adaptive targets.', tags: ['AIM', 'SPRAY'], tone: 'amber', progress: '42%', icon: 'target' },
    { index: '03', title: 'Rift Tactics', copy: 'Solve live scenarios with an AI coach that adapts to your habits.', tags: ['MAPS', 'AI COACH'], tone: 'purple', progress: '15%', icon: 'crosshair' },
    { index: '04', title: 'Team Protocols', copy: 'Coordinate executes, retakes and specialty windows with your squad.', tags: ['COMMS', 'UTILITY'], tone: 'green', progress: '0%', icon: 'users' },
  ]
  return <>
    <div className="page-heading"><div><div className="eyebrow">SIMULATION // TRAINING DECK</div><h1>Sharpen the edge.</h1><p>Five minutes here saves five rounds out there.</p></div><div className="ai-coach"><span className="ai-dot" />AI COACH <b>READY</b></div></div>
    <section className="training-hero panel"><div className="training-rings"><div /><div /><div /><span>KS3<br /><b>LAB</b></span></div><div className="training-hero-copy"><div className="eyebrow">ADAPTIVE TRAINING // BETA</div><h2>Practice with<br /><em>intent.</em></h2><p>The coach tracks your habits across aim, timing and comms, then builds the next scenario around the gap.</p><div className="coach-stats"><span><b>14</b> SCENARIOS</span><span><b>03</b> SKILL AXES</span><span><b>LIVE</b> FEEDBACK</span></div></div><button className="primary-button" onClick={() => onToast('Adaptive training session queued', 'success')}>START SESSION <Icon name="arrow" size={14} /></button></section>
    <SectionHeader eyebrow="TRAINING DECK // 04" title="Pick a drill" action="VIEW CURRICULUM" /><div className="drill-grid">{drills.map((drill) => <DrillCard drill={drill} key={drill.title} onStart={() => onToast(`${drill.title} drill loaded`, 'success')} />)}</div>
  </>
}

function DrillCard({ drill, onStart }) {
  return <article className={`panel drill-card drill-${drill.tone}`}><div className="drill-top"><span>{drill.index}</span><div className="drill-icon"><Icon name={drill.icon} size={20} /></div></div><div className="eyebrow">DRILL // {drill.tags.join(' · ')}</div><h3>{drill.title}</h3><p>{drill.copy}</p><div className="drill-progress-head"><span>MASTERY</span><b>{drill.progress}</b></div><div className="drill-progress"><span style={{ width: drill.progress }} /></div><div className="drill-footer"><div>{drill.tags.map((tag) => <span key={tag}>{tag}</span>)}</div><button onClick={onStart}><Icon name="play" size={11} /> START</button></div></article>
}

function FieldHud({ onToast }) {
  const [mode, setMode] = useState('LIVE HUD')
  return <>
    <div className="page-heading"><div><div className="eyebrow">COMBAT UI // FIELD READ</div><h1>Stay in the line.</h1><p>A low-noise HUD built for decisions under pressure.</p></div><div className="heading-status"><span className="status-pulse" />HUD PROFILE <b>TACTICAL</b></div></div>
    <div className="hud-tabs">{['LIVE HUD', 'POST-DEATH ECHO', 'SPECTATOR'].map((item) => <button className={mode === item ? 'is-active' : ''} key={item} onClick={() => setMode(item)}>{item}</button>)}</div>
    <section className={`hud-stage ${mode === 'POST-DEATH ECHO' ? 'echo-mode' : ''}`}>
      <div className="hud-map-bg"><div className="hud-scanline" /><div className="hud-landmark landmark-a">A</div><div className="hud-landmark landmark-b">B</div><div className="hud-route" /><div className="hud-contact contact-one" /><div className="hud-contact contact-two" /></div>
      <div className="hud-topline"><div className="hud-team team-left"><span className="team-pip" /><strong>HELIX</strong><b>04</b></div><div className="hud-round"><span>ROUND 07 // BUY PHASE</span><strong>01:42</strong><small>KEY NOT CARRIED</small></div><div className="hud-team team-right"><b>02</b><strong>RIFT CELL</strong><span className="team-pip enemy" /></div></div>
      <div className="hud-left-stack"><div className="hud-roster-label">YOUR FIRETEAM <span>4 / 5</span></div>{[['niko//zero','27','100',2],['mara.v','21','85',4],['k0met','18','100',1],['sable_06','16','42',3]].map((row, i) => <div className={`hud-roster-row ${i === 0 ? 'self' : ''}`} key={row[0]}><Avatar variant={row[3]} size="xs" /><div><strong>{row[0]}</strong><span>{i === 0 ? 'FEN-9' : i === 1 ? 'M-7' : 'KESTREL'}</span></div><b>{row[2]}</b></div>)}</div>
      <div className="hud-right-stack"><div className="hud-radar"><div className="radar-grid" /><i className="hud-radar-line" /><b className="hud-radar-blip b1" /><b className="hud-radar-blip b2" /><span className="radar-label">N</span></div><div className="hud-killfeed"><span><b>mara.v</b> + FEN-9 <em>k0met</em></span><span><b>RIFT//07</b> + VEX <em>sable_06</em></span></div></div>
      <div className="hud-center"><div className="hud-crosshair"><i /><i /><i /><i /><b /></div><div className="hud-callout"><span className="scan-dot" />CONTACT · A MAIN <b>12m</b></div></div>
      <div className="hud-bottom-left"><div className="hud-health"><strong>100</strong><span>HP</span></div><div className="hud-armor"><strong>85</strong><span>ARMOR</span></div><div className="hud-utility"><i>1</i><i>2</i><i>3</i><i>4</i></div></div>
      <div className="hud-bottom-right"><div className="hud-ammo"><strong>24 <small>/ 90</small></strong><span>FEN-9 // COBALT CIRCUIT</span></div><div className="hud-currency"><span>ROUND WALLET</span><b>₭ 2,850</b></div></div>
      {mode === 'POST-DEATH ECHO' && <div className="echo-overlay"><div className="echo-label"><Icon name="refresh" size={14} /> ECHO // LAST 03.0 SEC</div><strong>YOU ARE DOWN</strong><span>Review your line. No enemy silhouettes beyond confirmed vision.</span><button className="ghost-button" onClick={() => onToast('Echo dismissed', 'default')}>RETURN TO SPECTATE <Icon name="arrow" size={14} /></button></div>}
      {mode === 'SPECTATOR' && <div className="spectator-label"><span>OBSERVING</span><strong>MARA.V</strong><b>FREECAM LOCKED</b></div>}
    </section>
    <div className="hud-insight-grid"><section className="panel hud-insight"><SectionHeader eyebrow="HUD RULE // 01" title="Keep the center clean" /><p>Only actionable contact and objective cues can enter the crosshair lane. Damage, ammo and team state stay anchored to the edges.</p><div className="insight-line"><span>READ TIME</span><b>&lt; 240 ms</b></div><div className="insight-line"><span>COLOR DEPENDENCE</span><b>0%</b></div></section><section className="panel hud-insight"><SectionHeader eyebrow="HUD RULE // 02" title="Sound has a shape" /><p>Every important audio event receives a matching subtitle or directional marker, but visual cues never reveal an unseen enemy.</p><div className="sound-bars"><i /><i /><i /><i /><i /><i /><i /><i /><i /><i /><span>LOW</span><b>HIGH</b></div></section><section className="panel hud-insight"><SectionHeader eyebrow="HUD RULE // 03" title="Accessibility first" /><p>Reduce flash, enlarge text, colorblind-safe tags and motion-safe Echo are first-class options.</p><button className="text-button" onClick={() => onToast('Accessibility settings opened', 'success')}>OPEN ACCESSIBILITY <Icon name="arrow" size={14} /></button></section></div>
  </>
}

function PatchNotes() {
  return <>
    <div className="page-heading"><div><div className="eyebrow">COMMS // BUILD HISTORY</div><h1>Patch notes.</h1><p>What changed, what matters, what we are watching next.</p></div><div className="build-label"><span>LIVE BUILD</span><strong>0.9.4</strong><small>SEP 18, 2026</small></div></div>
    <div className="patch-layout"><div className="patch-main"><article className="patch-article panel"><div className="patch-article-head"><div><span className="patch-version">0.9.4</span><span className="patch-date">SEP 18, 2026</span></div><span className="patch-live"><i />LIVE</span></div><h2>Weather the storm.</h2><p className="patch-lead">The first live weather event arrives in Rift Protocol. Readability stays competitive; the world gets louder.</p><PatchSection title="SYSTEM // WEATHER EVENTS"><p>Overcast, rain and electrical storms can now rotate between rounds on Rift / Fall. Rain reduces long-range audio confidence by 8%; lightning briefly silhouettes agents in open space. Clear callouts remain unaffected.</p><div className="change-callout"><Icon name="shield" size={17} /><div><strong>Competitive guardrail</strong><span>Weather never changes weapon damage, spawn positions or hitbox visibility.</span></div></div></PatchSection><PatchSection title="MAP // RIFT / FALL"><ul><li>Added two breakable panels to A Main for deliberate line creation.</li><li>Raised B site cover by 12 cm to reduce accidental head glitches.</li><li>Adjusted sound zones around the Helix pump station.</li></ul></PatchSection><PatchSection title="WEAPONS // FEN-9"><p>First-shot recoil recovery reduced by 4%. The FEN-9 keeps its identity: stable when disciplined, expensive when panicked.</p></PatchSection></article></div><aside className="patch-aside"><div className="panel timeline-panel"><SectionHeader eyebrow="RECENT BUILDS" title="Release line" />{['0.9.4 // WEATHER','0.9.3 // HIT REG','0.9.2 // CASE LAB','0.9.0 // RIFT PROTOCOL'].map((item, i) => <div className={`timeline-row ${i === 0 ? 'current' : ''}`} key={item}><i /><div><strong>{item}</strong><span>{['SEP 18, 2026','SEP 11, 2026','SEP 04, 2026','AUG 28, 2026'][i]}</span></div></div>)}</div><div className="panel known-panel"><div className="eyebrow">KNOWN SIGNALS</div><h3>Watching the edges.</h3><p>We are monitoring queue balance in EU North and the new breakable cover around B site.</p><button className="text-button">OPEN STATUS <Icon name="arrow" size={14} /></button></div></aside></div>
  </>
}

function PatchSection({ title, children }) {
  return <div className="patch-section"><div className="patch-section-title"><span>{title}</span><i /></div>{children}</div>
}

function Profile({ onNavigate, onToast }) {
  return <>
    <div className="profile-hero"><div className="profile-cover" /><div className="profile-identity"><Avatar variant={2} size="xl" /><div><div className="eyebrow">OPERATOR // VERIFIED</div><h1>niko<span>//</span>zero</h1><p>Rift runner · EU North · active since 2024</p><div className="profile-tags"><span>VECTOR IV</span><span>SEASON 03</span><span><i /> ONLINE</span></div></div></div><button className="ghost-button" onClick={() => onToast('Profile share link copied', 'success')}>SHARE PROFILE <Icon name="arrow" size={14} /></button></div>
    <div className="profile-grid"><section className="panel profile-stats"><SectionHeader eyebrow="CAREER // ALL TIME" title="The numbers" /><div className="number-grid"><div><strong>486</strong><span>MATCHES</span></div><div><strong>1.24</strong><span>K/D RATIO</span></div><div><strong>58%</strong><span>WIN RATE</span></div><div><strong>6,840</strong><span>ELIMINATIONS</span></div></div><div className="profile-record"><span>BEST MAP</span><strong>RIFT / FALL</strong><b>62% WIN RATE</b></div><div className="profile-record"><span>FAVOURITE WEAPON</span><strong>FEN-9</strong><b>1,482 ELIMS</b></div></section><section className="panel achievement-panel"><SectionHeader eyebrow="ACHIEVEMENTS // 08 OF 32" title="Milestones" action="VIEW ALL" /><div className="achievement-list"><Achievement icon="star" title="First light" copy="Win your first ranked match" done /><Achievement icon="shield" title="Hold the line" copy="Win 10 rounds without dying" done /><Achievement icon="target" title="Thread the needle" copy="Land 3 wallbang eliminations" done /><Achievement icon="cube" title="Open the signal" copy="Acquire an Immortal item" progress="2 / 3" /></div></section></div>
    <SectionHeader eyebrow="RECENT LOADOUT" title="Your signature items" action="OPEN INVENTORY" onAction={() => onNavigate('loadout')} /><div className="signature-items">{items.slice(0, 4).map((item) => <InventoryCard item={item} key={item.name} onToast={onToast} />)}</div>
  </>
}

function Achievement({ icon, title, copy, done, progress }) {
  return <div className={`achievement ${done ? 'done' : ''}`}><div className="achievement-icon"><Icon name={icon} size={15} /></div><div><strong>{title}</strong><span>{copy}</span></div>{done ? <Icon name="check" size={15} /> : <b>{progress}</b>}</div>
}

function SettingsModal({ onClose, onToast }) {
  const [tab, setTab] = useState('VIDEO')
  return <div className="modal-backdrop"><div className="settings-modal modal-card"><div className="settings-head"><div><div className="eyebrow">SYSTEM // CONFIGURATION</div><h2>Settings</h2></div><button className="modal-close" onClick={onClose}><Icon name="close" size={17} /></button></div><div className="settings-body"><div className="settings-tabs">{['VIDEO', 'AUDIO', 'CONTROLS', 'CROSSHAIR'].map((item) => <button key={item} className={tab === item ? 'is-active' : ''} onClick={() => setTab(item)}>{item}</button>)}</div><div className="settings-content"><div className="settings-row"><div><strong>Display mode</strong><span>How KS3 occupies your screen</span></div><b>FULLSCREEN <Icon name="chevron" size={13} /></b></div><div className="settings-row"><div><strong>Resolution</strong><span>Native display resolution</span></div><b>2560 × 1440 <Icon name="chevron" size={13} /></b></div><div className="settings-row"><div><strong>Color profile</strong><span>Accessibility-first contrast tuning</span></div><b>TACTICAL <Icon name="chevron" size={13} /></b></div><div className="settings-slider"><div><strong>Master brightness</strong><b>82%</b></div><input type="range" defaultValue="82" /></div><div className="settings-toggle"><div><strong>Reduce menu motion</strong><span>Keep interaction feedback, soften transitions</span></div><i className="toggle is-on"><b /></i></div></div></div><div className="settings-footer"><span>Changes apply instantly</span><button className="primary-button" onClick={() => { onClose(); onToast('Settings saved', 'success') }}>SAVE & CLOSE</button></div></div></div>
}

function ProfileDrawer({ onClose, onNavigate }) {
  return <div className="drawer-backdrop" onClick={onClose}><aside className="profile-drawer" onClick={(event) => event.stopPropagation()}><div className="drawer-head"><span className="eyebrow">OPERATOR CARD</span><button className="modal-close" onClick={onClose}><Icon name="close" size={17} /></button></div><div className="drawer-identity"><Avatar variant={2} size="lg" /><h2>niko//zero</h2><span><i /> ONLINE · EU NORTH</span></div><div className="drawer-rank"><div className="rank-emblem"><div className="emblem-core">V</div><span>2,480</span></div><div><span>CURRENT SIGNAL</span><strong>VECTOR IV</strong><b>+124 THIS WEEK</b></div></div><div className="drawer-links"><button onClick={() => onNavigate('profile')}><Icon name="users" size={16} />VIEW PROFILE <Icon name="arrow" size={14} /></button><button onClick={() => onNavigate('loadout')}><Icon name="briefcase" size={16} />OPEN INVENTORY <Icon name="arrow" size={14} /></button><button><Icon name="shield" size={16} />PRIVACY & STATUS <span className="status-pulse" /></button></div><div className="drawer-footer"><span>KS3 ID // 8F-04-91</span><button>SWITCH ACCOUNT</button></div></aside></div>
}

export default App

createRoot(document.getElementById('root')).render(<App />)
