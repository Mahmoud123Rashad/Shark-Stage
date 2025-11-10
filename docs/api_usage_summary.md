# API Usage Summary (Flutter App)

هذا الملف يجمع كل الـ endpoints الخاصة بالباك‌اند التي يستدعيها تطبيق Flutter حاليًا، وما زال هناك مساحات من الـ API لم تُستخدم بعد مقارنةً بما توفره نسخة الويب (Next.js).

## 1. Authentication & User Session

| Endpoint | Method | الاستخدام في Flutter | ملاحظات |
| --- | --- | --- | --- |
| `POST /auth/signup` | JSON | `SignUpServices.signUpWithEmail` | تسجيل مستخدم جديد وحفظ الـ token إن وجد. |
| `POST /auth/signin` | JSON | `LoginService.login` | تسجيل الدخول بالبريد/كلمة المرور. |
| `POST /auth/google` | JSON | `SignUpServices.signInWithGoogle` | تسجيل عبر Google OAuth (يحتاج تأكيد دعم السيرفر). |
| `POST /auth/logout` | JSON | `SettingsList._logout` | تسجيل خروج، مع تجاهل الأخطاء إن فشل الطلب. |
| `GET /auth/me` | JSON | `ProfileService.fetchProfile` | جلب بيانات المستخدم وتحديث التخزين المحلي. |
| `PATCH /auth/profile` | JSON | `EditProfileService.updateProfile` | تحديث بيانات الحساب الأساسية (الاسم، الهاتف، البريد). |
| `POST /auth/upload-profile-picture` | Multipart | `ProfileService.uploadProfileImage` | رفع الصورة الشخصية بعد التحديث (خارج `ApiService`). |

**غير مستخدم حتى الآن في Flutter:**  
وجود API لتغيير كلمة المرور، إدارة الأمان، أو تفعيل OAuth إضافية يحتاج تأكيد. نسخة الويب تحتوي إعدادات أوسع (راجع ملفات `/account/profile`).

## 2. Projects

| Endpoint | Method | الاستخدام في Flutter | ملاحظات |
| --- | --- | --- | --- |
| `GET /projects` | JSON | `ProjectsScreen.fetchProjects`, `DashboardController._fetchProjects` (admin/investor fallback) | جلب قائمة المشاريع العامة. |
| `GET /projects/{id}` | JSON | `ProjectDetailsService.fetchProjectDetails`, `DashboardController` (للاستثمارات) | جلب تفاصيل مشروع محدد. |
| `GET /projects/user/{userId}` | JSON | `DashboardController._fetchProjects` (role=owner) | جلب مشاريع المالك. |
| `POST /projects/add` | Multipart | `ProjectController.saveProject` | إنشاء مشروع جديد (صورة فقط). |

**غير مستخدم بعد:**  
- `PUT/PATCH /projects/{id}` أو endpoints لتعديل/حذف مشروع.  
- أي فلاتر متقدمة (category/status/ROI) عبر query params.  
- Endpoints لإدارة المستندات/العروض الخاصة بالمشروع (إن وُجدت).

## 3. Investments & Offers

| Endpoint | Method | الاستخدام في Flutter | ملاحظات |
| --- | --- | --- | --- |
| `GET /investments/user/{userId}` | JSON | `DashboardController._fetchProjects` للـ investor | يجلب استثمارات المستخدم مع نسبة الاستثمار. |

**غير مستخدم:**  
- Endpoints لإرسال عرض استثمار، قبول/رفض، متابعة حالة العرض.  
- مسارات لإدارة المدفوعات، الأرباح، أو التتبع المالي (متوفر في الويب عبر Offers/Messaging).

## 4. Chatbot & Messaging

| Endpoint | Method | الاستخدام في Flutter | ملاحظات |
| --- | --- | --- | --- |
| `POST /chatbot/ask` | JSON | `ChatBotService.sendMessage` | إرسال سؤال للـ chatbot مع تحديد اللغة. |

**غير مستخدم:**  
- أي Endpoints خاصة بالرسائل بين المستخدمين أو محادثات العروض (متوفرة في الويب عبر `/chat` أو `/account/messages`).

## 5. Dashboard Metrics

| Endpoint | Method | الاستخدام في Flutter | ملاحظات |
| --- | --- | --- | --- |
| (يعتمد على ما سبق) | | `DashboardController` يستخدم `/projects`, `/projects/user`, `/investments/user` | لا يوجد Endpoint مستقل للإحصائيات كما هو في الويب؛ يتم اشتقاق الأرقام محليًا. |

**غير مستخدم:**  
- إن كان في الباك‌اند endpoints جاهزة لإرجاع إحصائيات جاهزة (total capital, ROI, notifications)، يمكن الاستفادة منها لاحقًا.

## 6. Files & Assets

- حاليًا: رفع صورة للمشروع (`image`)، رفع صورة للبروفايل (`profilePicUrl`).
- غير مستخدم: رفع مستندات إضافية للمشروع (`pitchDeck`, `documents`) إذا سمح السيرفر مستقبلًا.

## 7. Endpoints موجودة في نسخة الويب فقط (ولا تزال غير مستخدمة في Flutter)

مستخلصة من ملفات Next.js (`sharkstage/app`) وملفات الـ API المشتركة:

| فئة | أمثلة للأندبوينت | موقعها في الويب |
| --- | --- | --- |
| Offers | `/offers`, `/offers/{id}`, `/offers/respond` | `app/(dashboard)/account/offers` |
| Messaging | `/messages`, `/messages/{conversationId}` | `app/chat`, `app/(dashboard)/account/messages` |
| Admin tools | `/admin/*` | أي صفحات إدارية إن وجدت |
| Reports & downloads | `/reports/*` | أزرار تقرير في صفحة الداشبورد (تحميل CSV/PDF) |
| Notifications | `/notifications` | لإرجاع أو تحديث الإشعارات |
| Category/filters metadata | `/categories`, `/filters` | إن كان يتم استخدامها لتوليد فلاتر ديناميكية في الويب |

> **ملاحظة:** بعض هذه المسارات تحتاج تأكيد من كود الباك‌اند (`sharkserver`). المستند يهدف لتوجيه العمل القادم؛ يوصى بمراجعة الكود الخلفي أو Swagger (إن وجد) للتأكد قبل التنفيذ.

---
## توصيات للخطوات القادمة

1. **إكمال التكامل مع Offers/Messaging** — ستكون ضرورية لتحقيق التكافؤ مع الويب.
2. **تدفق تعديل المشروع** — إضافة شاشات `edit` و`delete` لاستخدام `/projects/{id}` (PATCH/DELETE).
3. **استغلال Endpoints إضافية للإحصائيات** — تحسين أداء الداشبورد بدل إعادة الحساب client-side.
4. **توثيق أي Endpoint جديد** مباشرة في هذا الملف للحفاظ على المرجعية.

> تم تحديث هذه القائمة بناءً على الشيفرة الحالية (نوفمبر 2025). عند إضافة ميزات جديدة، يرجى تحديث الملخص.

