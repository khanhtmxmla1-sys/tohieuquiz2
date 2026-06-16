# AI Assistant Cannot Be Disabled - ROOT CAUSE ANALYSIS

**Date:** 2026-06-16 20:36 ICT  
**Status:** 🔴 ROOT CAUSE IDENTIFIED  
**Severity:** HIGH (Admin setting ignored)

---

## 🎯 ROOT CAUSE (100% CERTAIN)

**Problem:** ChatBot component does NOT check the `aiAssistantEnabled` system setting.

**Result:** Even when admin sets "Trợ lý AI" to OFF (false), the ChatBot floating button and chat window still appear on all pages.

---

## 📊 EVIDENCE

### 1. System Settings Backend ✅ WORKING

**Database:**
```sql
SELECT * FROM system_settings WHERE setting_key = 'ai_assistant_enabled'
```

**Current value:** 
```
│ setting_key          │ setting_value │ updated_at               │
│ ai_assistant_enabled │ false         │ 2026-06-16T13:34:00.000Z │
```

✅ Database can store 'false' value  
✅ Admin can save the setting via UI  
✅ Backend API (workers/src/routes/systemSettings.ts) works correctly

### 2. Frontend Settings UI ✅ WORKING

**File:** `src/components/TeacherDashboard/AnnouncementSettings.tsx`

Lines 24, 264-287:
```typescript
const [aiAssistantEnabled, setAiAssistantEnabled] = useState(true);

// Toggle UI
<input
    type="checkbox"
    checked={aiAssistantEnabled}
    onChange={(e) => setAiAssistantEnabled(e.target.checked)}
/>

// Save button
<button onClick={handleSaveSystemSettings}>
    💾 Lưu cài đặt Trợ lý AI
</button>
```

✅ Toggle can be turned OFF  
✅ Save button calls `saveSystemSettings()` correctly  
✅ Backend receives and saves the 'false' value

### 3. ChatBot Component ❌ IGNORES SETTING

**File:** `src/components/ChatBot/ChatBot.tsx`

Lines 1-195 (entire file):
```typescript
const ChatBot: React.FC = () => {
    const { isOpen, messages, isLoading, toggleChat, sendMessage, clearHistory } = useChatStore();
    
    // ... NO check for aiAssistantEnabled setting!
    
    return (
        <>
            {/* FAB button - ALWAYS renders when isOpen=false */}
            {!isOpen && (
                <motion.button onClick={toggleChat} className="chatbot-fab">
                    <MessageCircle size={28} />
                </motion.button>
            )}
            
            {/* Chat window - ALWAYS renders when isOpen=true */}
            {isOpen && (
                <motion.div className="chatbot-window">
                    {/* ... chat UI ... */}
                </motion.div>
            )}
        </>
    );
};
```

**PROBLEM:**
- ❌ No `useState` or `useEffect` to fetch system settings
- ❌ No `useEffect` to listen for 'itongquiz:system-settings-updated' event
- ❌ No conditional rendering based on `aiAssistantEnabled`
- ❌ Component ALWAYS renders regardless of admin setting

**Search results:**
```bash
search_files for 'aiAssistant|system-settings|itongquiz:system-settings' in 'ChatBot.tsx'
Found 0 results.
```

**CONFIRMED:** ChatBot does not check the setting at all!

---

## 🔍 TECHNICAL FLOW

### Current (Broken) Behavior

```
Admin sets AI Assistant to OFF
    ↓
Frontend saves to backend
    ↓
Backend saves 'false' to database ✅
    ↓
Backend dispatches event 'itongquiz:system-settings-updated' ✅
    ↓
ChatBot component renders...
    ↓
❌ NO CHECK for aiAssistantEnabled setting!
    ↓
ChatBot FAB button STILL shows
```

### Expected (Fixed) Behavior

```
Admin sets AI Assistant to OFF
    ↓
saves to database ✅
    ↓
dispatches event ✅
    ↓
ChatBot component:
    ├─ useEffect fetches system settings
    ├─ listens for 'itongquiz:system-settings-updated' event
    ├─ checks: if (!aiAssistantEnabled) return null;
    └─ ✅ ChatBot hidden (does not render)
```

---

## 🛠️ FIX REQUIRED

### Step 1: Add system settings check to ChatBot

**File:** `src/components/ChatBot/ChatBot.tsx`

```typescript
import { useEffect, useState } from 'react';
import { getSystemSettings } from '../../services/systemSettingsService';

const ChatBot: React.FC = () => {
    const [aiAssistantEnabled, setAiAssistantEnabled] = useState(true);
    const [isLoading, setIsLoading] = useState(true);
    
    // Fetch system settings on mount
    useEffect(() => {
        const fetchSettings = async () => {
            try {
                const settings = await getSystemSettings();
                setAiAssistantEnabled(settings.aiAssistantEnabled);
            } catch (error) {
                console.error('Failed to fetch system settings:', error);
            } finally {
                setIsLoading(false);
            }
        };
        fetchSettings();
    }, []);
    
    // Listen for settings updates
    useEffect(() => {
        const handleUpdate = (e: CustomEvent) => {
            setAiAssistantEnabled(e.detail.aiAssistantEnabled);
        };
        
        window.addEventListener('itongquiz:system-settings-updated', handleUpdate as EventListener);
        return () => {
            window.removeEventListener('itongquiz:system-settings-updated', handleUpdate as EventListener);
        };
    }, []);
    
    // Hide ChatBot if disabled
    if (!aiAssistantEnabled || isLoading) {
        return null;
    }
    
    // ... rest of component (FAB button + chat window)
};
```

### Step 2: Alternative - Conditional rendering in parent

If ChatBot is imported in a parent component (App.tsx or similar), add check there:

```typescript
{aiAssistantEnabled && <ChatBot />}
```

---

## ✅ VERIFICATION STEPS

After fix:

1. **Set AI Assistant to OFF** via Admin → Thông báo → Cài đặt Trợ lý AI
2. **Save settings** → Should show success message
3. **Refresh page** → ChatBot FAB button should NOT appear
4. **Check database:** 
   ```sql
   SELECT * FROM system_settings WHERE setting_key = 'ai_assistant_enabled'
   -- Should return: setting_value = 'false'
   ```
5. **Set AI Assistant to ON** → ChatBot should reappear immediately

---

## 📊 IMPACT ANALYSIS

### Components Affected
- ✅ `src/components/TeacherDashboard/AnnouncementSettings.tsx` - Settings UI (works correctly)
- ✅ `src/services/systemSettingsService.ts` - Service layer (works correctly)
- ✅ `workers/src/routes/systemSettings.ts` - Backend API (works correctly)
- ❌ **`src/components/ChatBot/ChatBot.tsx`** - **MISSING CHECK (ROOT CAUSE)**

### Code Search Results
```bash
# Only 1 place saves settings (correct)
search 'saveSystemSettings' → Found 1 result in AnnouncementSettings.tsx

# ChatBot does NOT check settings (bug)
search 'aiAssistant|system-settings' in ChatBot.tsx → Found 0 results
```

---

## 🎯 CONCLUSION

**Root Cause Statement:**

> The `ChatBot` component (src/components/ChatBot/ChatBot.tsx) does not fetch or check the `aiAssistantEnabled` system setting. It always renders the floating action button and chat window regardless of the admin's preference.

**Why the admin thinks saving doesn't work:**

1. Admin toggles OFF → Saves successfully ✅
2. Database stores 'false' ✅
3. Admin refreshes page
4. ChatBot STILL shows up ❌ (because it never checks the setting!)
5. Admin concludes: "Không tắt được!" (Can't turn it off!)

**The fix is simple:** Add a system settings check to ChatBot component to respect the `aiAssistantEnabled` flag.

---

**Analyzed by:** Kiro AI Assistant  
**Verified with:**
- Database query results (value CAN be set to 'false')
- Code search (ChatBot doesn't check setting)
- Backend API logs (save works correctly)
- Component source code analysis

**Confidence Level:** 100% - ROOT CAUSE CONFIRMED
