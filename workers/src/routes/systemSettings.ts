import { Env } from '../types';
import { errorResponse, jsonResponse } from '../utils/response';
import { parseBody } from '../utils/helpers';
import { verifyJWTMiddleware, requireAdmin } from '../middleware/jwtAuth';
import { JWTPayload } from '../utils/jwt';

type SystemSettingRow = {
    setting_key: string;
    setting_value: string;
    updated_at: string;
};

const AI_ASSISTANT_KEY = 'ai_assistant_enabled';

const parseBool = (value: unknown, fallback = false): boolean => {
    if (typeof value === 'boolean') return value;
    if (typeof value === 'number') return value === 1;
    if (typeof value === 'string') {
        const normalized = value.trim().toLowerCase();
        if (normalized === 'true' || normalized === '1') return true;
        if (normalized === 'false' || normalized === '0') return false;
    }
    return fallback;
};

const ensureSystemSettingsTable = async (db: D1Database): Promise<void> => {
    await db.prepare(`
        CREATE TABLE IF NOT EXISTS system_settings (
            setting_key TEXT PRIMARY KEY,
            setting_value TEXT NOT NULL,
            updated_at TEXT NOT NULL
        )
    `).run();

    await db.prepare(`
        INSERT OR IGNORE INTO system_settings (setting_key, setting_value, updated_at)
        VALUES (?, ?, ?)
    `).bind(AI_ASSISTANT_KEY, 'true', new Date().toISOString()).run();
};

const isAdminActor = async (db: D1Database, actorUsername: string): Promise<boolean> => {
    const username = String(actorUsername || '').trim();
    if (!username) return false;
    const actor = await db.prepare('SELECT role FROM teachers WHERE username = ?').bind(username).first<any>();
    return String(actor?.role || '').trim().toLowerCase() === 'admin';
};

export async function handleSystemSettingsRoutes(request: Request, env: Env, path: string, method: string): Promise<Response | null> {
    if (path !== '/api/system-settings') return null;

    const db = env.DB;
    await ensureSystemSettingsTable(db);

    if (method === 'GET') {
        const row = await db.prepare(`
            SELECT setting_key, setting_value, updated_at
            FROM system_settings
            WHERE setting_key = ?
            LIMIT 1
        `).bind(AI_ASSISTANT_KEY).first<SystemSettingRow>();

        const aiAssistantEnabled = parseBool(row?.setting_value ?? 'true', true);
        return jsonResponse({
            status: 'success',
            data: {
                aiAssistantEnabled,
                updatedAt: row?.updated_at || '',
            },
        });
    }

    if (method === 'POST') {
        // SECURITY: Verify JWT token and require admin role
        const authResult = await verifyJWTMiddleware(request, env);
        if (authResult instanceof Response) return authResult;
        const { user } = authResult; // Extract user from { user: JWTPayload }

        // Only admins can modify system settings
        if (!(await isAdminActor(db, user.username))) {
            return errorResponse('Forbidden: Admin role required', 403);
        }

        const body = await parseBody(request);
        if (!body) return errorResponse('Invalid JSON body');

        const aiAssistantEnabled = parseBool(body.aiAssistantEnabled, true);
        const now = new Date().toISOString();

        await db.prepare(`
            INSERT INTO system_settings (setting_key, setting_value, updated_at)
            VALUES (?, ?, ?)
            ON CONFLICT(setting_key) DO UPDATE SET
                setting_value = excluded.setting_value,
                updated_at = excluded.updated_at
        `).bind(AI_ASSISTANT_KEY, aiAssistantEnabled ? 'true' : 'false', now).run();

        return jsonResponse({
            status: 'success',
            data: {
                aiAssistantEnabled,
                updatedAt: now,
            },
        });
    }

    return errorResponse('Method not allowed', 405);
}

