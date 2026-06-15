# HƯỚNG DẪN FIX: Thêm Live Exam API Endpoints vào apiAdapter.ts

## 📍 VỊ TRÍ CÁN SỬA

File: `src/services/apiAdapter.ts`

## 🔧 BƯỚC 1: Thêm Live Exam Cases vào Switch Statement

### Tìm vị trí chèn code:

Mở file `src/services/apiAdapter.ts`, tìm dòng:
```typescript
case 'save_system_settings': method = 'POST'; path = '/api/system-settings'; break;
```

**Ngay sau dòng này** (khoảng dòng 164), thêm section Live Exam:

```typescript
        // --- Live Exam ---
        case 'get_live_exam_sessions':
            method = 'GET';
            path = `/api/live-exam/teacher/${encodeURIComponent(payload.teacherUsername)}/sessions`;
            break;

        case 'create_live_exam_session':
            method = 'POST';
            path = '/api/live-exam/create';
            break;

        case 'get_live_exam_session':
            method = 'GET';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}`;
            break;

        case 'control_live_exam_session':
            method = 'POST';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/control`;
            break;

        case 'delete_live_exam_session':
            method = 'DELETE';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}`;
            break;

        case 'get_live_exam_participants':
            method = 'GET';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/participants`;
            break;

        case 'join_live_exam':
            method = 'POST';
            path = '/api/live-exam/join';
            break;

        case 'get_live_exam_status':
            method = 'GET';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/status`;
            break;

        case 'submit_live_exam':
            method = 'POST';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/submit`;
            break;

        case 'update_live_exam_activity':
            method = 'POST';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/activity`;
            break;

        case 'get_live_exam_results':
            method = 'GET';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/results`;
            break;

        case 'get_live_exam_chat':
            method = 'GET';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/chat`;
            break;

        case 'send_live_exam_chat_message':
            method = 'POST';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/chat/message`;
            break;

        case 'send_live_exam_announcement':
            method = 'POST';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/chat/announcement`;
            break;

        case 'update_live_exam_chat_settings':
            method = 'PUT';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/chat/settings`;
            break;

        case 'hide_live_exam_chat_message':
            method = 'PUT';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/chat/${encodeURIComponent(payload.messageId)}/hide`;
            break;

        case 'track_live_exam_timing':
            method = 'POST';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/track-timing`;
            break;

        case 'get_live_exam_analytics':
            method = 'GET';
            path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/analytics`;
            break;
```

---

## 🔧 BƯỚC 2: Thêm Live Exam vào JWT Routes Check

### Tìm vị trí:

Trong cùng file `src/services/apiAdapter.ts`, tìm dòng (khoảng dòng 195-212):

```typescript
const isJWTRoute = path === '/api/login' ||
                  path === '/api/student-login' ||
                  path === '/api/logout' ||
                  path.startsWith('/api/game-loop') ||
                  path.startsWith('/api/teachers') ||
                  path.startsWith('/api/classes') ||
                  path.startsWith('/api/students') ||
                  path.startsWith('/api/assignments') ||
                  path.startsWith('/api/results') ||
                  path === '/api/validate' ||
                  path.startsWith('/api/quizzes') ||
                  path.startsWith('/api/questions') ||
                  // NEW: Migrated to JWT authentication
                  path === '/api/system-settings' ||
                  path.startsWith('/api/leaderboard') ||
                  path.startsWith('/api/game-state') ||
                  path.startsWith('/api/gift-shop') ||
                  path.startsWith('/api/shop');
```

### Sửa thành:

Thêm dòng `path.startsWith('/api/live-exam')` vào cuối (trước dấu `;`):

```typescript
const isJWTRoute = path === '/api/login' ||
                  path === '/api/student-login' ||
                  path === '/api/logout' ||
                  path.startsWith('/api/game-loop') ||
                  path.startsWith('/api/teachers') ||
                  path.startsWith('/api/classes') ||
                  path.startsWith('/api/students') ||
                  path.startsWith('/api/assignments') ||
                  path.startsWith('/api/results') ||
                  path === '/api/validate' ||
                  path.startsWith('/api/quizzes') ||
                  path.startsWith('/api/questions') ||
                  // NEW: Migrated to JWT authentication
                  path === '/api/system-settings' ||
                  path.startsWith('/api/leaderboard') ||
                  path.startsWith('/api/game-state') ||
                  path.startsWith('/api/gift-shop') ||
                  path.startsWith('/api/shop') ||
                  path.startsWith('/api/live-exam');  // ← THÊM DÒNG NÀY
```

---

## ✅ KIỂM TRA SAU KHI SỬA

### 1. Compile Check:
```bash
npm run build
```

Đảm bảo không có lỗi TypeScript.

### 2. Test Runtime:

Mở Teacher Dashboard → Thi Trực Tiếp:
- ✅ Không còn lỗi "Unknown API action"
- ✅ Danh sách phiên thi load được
- ✅ Có thể tạo phiên thi mới
- ✅ Không còn 401/404/500 errors

---

## 📊 GIẢI THÍCH CÁC CASE

### Pattern chung:
```typescript
case 'tên_action':
    method = 'HTTP_METHOD';  // GET, POST, PUT, DELETE
    path = '/api/endpoint';   // URL endpoint
    break;
```

### Ví dụ cụ thể:

**1. Get Sessions (Teacher xem danh sách phiên thi của mình):**
```typescript
case 'get_live_exam_sessions':
    method = 'GET';
    path = `/api/live-exam/teacher/${encodeURIComponent(payload.teacherUsername)}/sessions`;
    break;
```
- Action: `get_live_exam_sessions`
- Method: `GET` (đọc data)
- Path: `/api/live-exam/teacher/{username}/sessions`
- Payload cần: `{ teacherUsername: "admin" }`

**2. Create Session (Teacher tạo phiên thi mới):**
```typescript
case 'create_live_exam_session':
    method = 'POST';
    path = '/api/live-exam/create';
    break;
```
- Action: `create_live_exam_session`
- Method: `POST` (tạo mới)
- Path: `/api/live-exam/create`
- Payload: `{ title, quizId, classId, ... }`

**3. Control Session (Teacher điều khiển phiên thi: open/start/end):**
```typescript
case 'control_live_exam_session':
    method = 'POST';
    path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}/control`;
    break;
```
- Action: `control_live_exam_session`
- Method: `POST` (thay đổi trạng thái)
- Path: `/api/live-exam/{sessionId}/control`
- Payload: `{ sessionId: "abc123", control: "start" }`

**4. Join Session (Student tham gia phiên thi):**
```typescript
case 'join_live_exam':
    method = 'POST';
    path = '/api/live-exam/join';
    break;
```
- Action: `join_live_exam`
- Method: `POST`
- Path: `/api/live-exam/join`
- Payload: `{ accessCode: "ABC123", studentId: "hs001" }`

**5. Delete Session:**
```typescript
case 'delete_live_exam_session':
    method = 'DELETE';
    path = `/api/live-exam/${encodeURIComponent(payload.sessionId)}`;
    break;
```
- Action: `delete_live_exam_session`
- Method: `DELETE` (xóa)
- Path: `/api/live-exam/{sessionId}`
- Payload: `{ sessionId: "abc123" }`

---

## 🔐 JWT Authentication

Sau khi thêm `path.startsWith('/api/live-exam')` vào `isJWTRoute`:

- ✅ Tất cả Live Exam endpoints sẽ sử dụng JWT cookie authentication
- ✅ Frontend tự động gửi JWT token trong header
- ✅ Backend verify token và extract user info
- ✅ Không cần truyền username trong URL nữa (trừ get_sessions)

---

## 📝 CÁC ACTION CẦN THIẾT

Tổng cộng **18 actions** cần thêm:

### Teacher Actions (7):
1. `get_live_exam_sessions` - Xem danh sách phiên thi
2. `create_live_exam_session` - Tạo phiên thi mới
3. `get_live_exam_session` - Xem chi tiết 1 phiên thi
4. `control_live_exam_session` - Điều khiển (open/start/end)
5. `delete_live_exam_session` - Xóa phiên thi
6. `get_live_exam_participants` - Xem danh sách học sinh
7. `get_live_exam_analytics` - Xem thống kê analytics

### Student Actions (5):
8. `join_live_exam` - Tham gia phiên thi
9. `get_live_exam_status` - Poll trạng thái phiên thi
10. `submit_live_exam` - Nộp bài
11. `update_live_exam_activity` - Cập nhật hoạt động (tracking)
12. `get_live_exam_results` - Xem kết quả

### Chat Actions (5):
13. `get_live_exam_chat` - Lấy messages
14. `send_live_exam_chat_message` - Gửi message
15. `send_live_exam_announcement` - Gửi thông báo (teacher only)
16. `update_live_exam_chat_settings` - Bật/tắt chat
17. `hide_live_exam_chat_message` - Ẩn message (teacher only)

### Tracking Action (1):
18. `track_live_exam_timing` - Track thời gian làm từng câu hỏi

---

## 🎯 TÓM TẮT

**Cần sửa 2 chỗ trong file `src/services/apiAdapter.ts`:**

1. **Thêm 18 case statements** cho Live Exam (sau dòng 164)
2. **Thêm 1 dòng** vào JWT routes check (dòng 212): `path.startsWith('/api/live-exam')`

**Tổng số dòng code thêm:** ~75 dòng

**Thời gian ước tính:** 5-10 phút copy-paste và test

---

## ❓ CÂU HỎI THƯỜNG GẶP

**Q: Tại sao phải dùng `encodeURIComponent()`?**  
A: Để encode URL-safe cho các tham số có thể chứa ký tự đặc biệt.

**Q: Tại sao `get_live_exam_sessions` cần `teacherUsername` trong URL?**  
A: Vì endpoint này filter theo teacher. Backend cũng verify JWT để đảm bảo teacher chỉ xem được phiên thi của mình.

**Q: Method GET và DELETE có body không?**  
A: Không. Xem dòng 224-226 trong apiAdapter:
```typescript
if (method !== 'GET' && method !== 'DELETE') {
    fetchOptions.body = JSON.stringify(payload);
}
```

**Q: Nếu sửa sai thì sao?**  
A: TypeScript compiler sẽ báo lỗi khi build. Nếu runtime error, check browser console để debug.

---

**Chúc bạn fix thành công! 🚀**
