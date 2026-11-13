# P13 — Traffic Signal Fault Dispatcher

A working hackathon implementation of the P13 brief using **React + Flask + SQLite**. The Python backend is the source of truth for DFA/regex validation, classification, priority, routing, dispatch, queue ordering, status transitions and analytics.

## Features

- Junction ID DFA and equivalent regex: `J(NORTH|SOUTH|EAST|WEST)[0-9]{3}`.
- Fault code DFA and equivalent regex: `F[0-9]{2}`.
- Five exclusive categories and category-based priority.
- Four depots, fixed illustrative distance matrix, handler availability/capacity and van reservations.
- Nearest-first depot selection, backup depot assignment, critical escalation history and deterministic pending queue.
- SQLite persistence, status history and routing decision log.
- Five React interfaces: report submission, user dashboard, handler dashboard, routing management and analytics.
- Role-protected Flask endpoints and 16+ automated tests.

## Important documented simulation assumptions

1. The official problem statement and supplied handwritten notes do not define a real-world mapping for F01–F99. The initial editable demonstration mapping is F01 → Arterial-Blocked, F02 → Signal-Dark, F03 → Partial-Fault, F04 → Flashing-Mode and F05 → Minor. This is explicitly a **simulation assumption**, not an official fault-code standard. Other syntactically valid codes are rejected at classification until configured by an administrator.
2. Distance values are the illustrative values in the project specification, in kilometres; they are not live geographical measurements.
3. Initial resources are three vans per depot and two handlers per depot, each with capacity two active reports.
4. Category priority is: Arterial-Blocked / Signal-Dark rank 1 (Critical), Partial-Fault rank 2 (Medium), Flashing-Mode rank 3 (Low), Minor rank 4 (Lowest).
5. The application includes a basic demonstration login. Change the development secret and passwords before any public deployment. This is a hackathon prototype, not a production emergency dispatch service.

## Requirements

- Python 3.10+
- Node.js 18+ and npm

## Run locally (Windows PowerShell)

### 1. Start the Flask backend

```powershell
cd traffic-signal-fault-dispatcher\backend
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python app.py
```

The API runs at `http://localhost:5000`. SQLite is created automatically at `backend/traffic_dispatcher.db` on first start.

### 2. Start the React frontend (new terminal)

```powershell
cd traffic-signal-fault-dispatcher\frontend
npm install
npm run dev
```

Open the Vite URL shown in the terminal (normally `http://localhost:5173`). The frontend uses `http://localhost:5000/api` by default. To change it, create `frontend/.env` with `VITE_API_URL=http://localhost:5000/api` and restart Vite.

### Demo accounts

| Role | Username | Password |
|---|---|---|
| Reporter | `reporter` | `report123` |
| Administrator | `admin` | `admin123` |
| Handler | `alphahandler1` | `demo123` |
| Other handlers | `betahandler1`, `gammahandler1`, `deltahandler1` | `demo123` |

The UI also has role shortcuts on the login page. The backend enforces roles; hiding a menu item is not the security boundary.

## Recommended demo workflow

1. Sign in as `reporter` and submit `JNORTH001`, `F01`, with a short description.
2. Note the generated `TSF-XXXXXXXX` report ID and assigned depot/handler.
3. Sign in as the assigned handler (the initial North nearest depot is Alpha; use `alphahandler1` / `demo123`).
4. Move the report from Assigned → In Progress → Resolved.
5. Sign in as `admin` and inspect active assignments, depot resources, queue, decision history and escalations.
6. Open Analytics Dashboard to see database-backed charts update.
7. To demonstrate queueing, temporarily set all available vans to zero from Routing Management, submit another report, then restore a van. Queue reprocessing occurs after resource updates.

## Tests

From `backend/`:

```powershell
pip install -r requirements.txt
pytest -v
```

The tests cover DFA/regex agreement, valid and invalid identifiers, five-category mapping, unknown classification codes, zone extraction, API authentication, invalid report rejection, report persistence/tracking, role protection and analytics updates.

## API overview

- `POST /api/auth/login`
- `POST /api/reports/validate`
- `POST /api/reports`
- `GET /api/reports`, `GET /api/reports/<report_id>`
- `PATCH /api/reports/<report_id>/status`
- `GET /api/reports/<report_id>/history`
- `GET /api/handlers`, `GET /api/handlers/me/reports`, `PATCH /api/handlers/me`
- `GET /api/routing/overview`, `GET /api/queue`
- `PATCH /api/admin/depots/<id>`, `PATCH /api/admin/handlers/<id>`
- `GET /api/admin/classification-rules`, `PUT /api/admin/classification-rules/<code>`
- `GET /api/analytics`

## Architecture

```text
frontend/                 React + Vite + Recharts
backend/app.py            Flask REST API + role checks + workflow orchestration
backend/domain.py         DFA, regex, validation, classification and priority rules
backend/database.py       SQLite schema and initial seed data
backend/tests/            Automated tests
```

## Deployment note

For a public deployment, set a strong `SECRET_KEY`, restrict CORS to the deployed frontend origin, use HTTPS, rotate demo credentials, add rate limiting/audit controls, and use a managed persistent disk for SQLite or migrate to a server database if concurrent production use is expected. The brief requests SQLite, so this implementation keeps SQLite.

## Run online on Replit (no local Python installation)
1. Open https://replit.com/import and choose ZIP.
2. Upload the project ZIP downloaded from this chat.
3. After import, open the Shell and run `bash start.sh` (or click Run if Replit detects `.replit`).
4. Open the Webview preview. Vite proxies `/api` requests to the Flask backend.

The Replit setup uses the same Flask + SQLite + React architecture. It does not replace SQLite with MongoDB.
