"""Migration integrity test.

Runs real `alembic upgrade head` and `alembic downgrade base` as
subprocesses against a fresh, isolated SQLite file — not mocked, not
skipped. This is the test that would have caught every migration typo
this project hit earlier (missing quotes in ForeignKeyConstraint, a
double-underscore table name, a missing downgrade() function, a
down_revision pointing at a nonexistent file) automatically on the PR,
instead of surfacing as a runtime error on someone's machine later.
"""

import os
import subprocess
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[1]


def test_alembic_upgrade_and_downgrade_run_cleanly(tmp_path):
    db_path = tmp_path / "migration_ci_test.db"
    env = os.environ.copy()
    env["DATABASE_URL"] = f"sqlite:///{db_path}"

    upgrade_result = subprocess.run(
        ["alembic", "upgrade", "head"],
        cwd=BACKEND_DIR,
        env=env,
        capture_output=True,
        text=True,
    )
    assert upgrade_result.returncode == 0, (
        f"alembic upgrade head failed:\nstdout: {upgrade_result.stdout}\n"
        f"stderr: {upgrade_result.stderr}"
    )

    downgrade_result = subprocess.run(
        ["alembic", "downgrade", "base"],
        cwd=BACKEND_DIR,
        env=env,
        capture_output=True,
        text=True,
    )
    assert downgrade_result.returncode == 0, (
        f"alembic downgrade base failed:\nstdout: {downgrade_result.stdout}\n"
        f"stderr: {downgrade_result.stderr}"
    )