# Flutter ↔ Web Parity Gaps

هذا المستند يلخص أهم الميزات/التجارب الموجودة في نسخة الويب (Next.js) ولم تُنفَّذ بعد في تطبيق Flutter، ليكون مرجعًا واضحًا لخطوات التطوير القادمة. تم ترتيب البنود حسب تأثيرها على تجربة المستخدم.

## 1. قوائم المشاريع (فِلترة/بحث/تصنيف)
- **الوضع الحالي في الويب:** Redux + فِلتر بحسب الفئة، الحالة، ROI، البحث النصي، والفرز مع تقسيم الصفحات.
- **الوضع الحالي في Flutter:** قائمة واحدة بدون فلاتر أو Pagination.
- **ملفات مرجعية:**  
  - Web: `sharkstage/app/(main)/projects/page.jsx`, `sharkstage/lib/features/projects`.  
  - Flutter: `lib/screens/projects_screen`, `lib/screens/projects_screen/project_card.dart`.
- **العمل المطلوب:**  
  - بناء طبقة state management (مثلاً Provider أو Riverpod) لتحاكي Redux.  
  - إضافة واجهة فِلتر/بحث/فرز وتحديث الاستعلامات تجاه `/projects`.  
  - دعم Pagination أو lazy-loading.

## 2. صفحة تفاصيل المشروع الموسَّعة
- **الويب:** يعرض progress، expected ROI، milestones، team، documents، investors، إلخ.
- **Flutter:** يعرض العنوان والوصف وبعض الحقول الأساسية فقط.
- **ملفات مرجعية:**  
  - Web: `sharkstage/app/(main)/projects/[id]/page.jsx`.  
  - Flutter: `lib/screens/project_details/project_details_screen.dart`, `lib/widgets/project_details_body.dart`.
- **المهام:**  
  - جلب الحقول الإضافية من `/projects/{id}` وعرضها.  
  - تصميم أقسام الملخص، الفريق، المستندات (مع فتح PDF/روابط).  
  - عرض progress والرسوم/المخططات إن وُجدت.

## 3. إدارة المشاريع لحساب المالك/المستثمر
- **الويب:** صفحة `/account/projects` بها تبويبات/فلاتر، حالات متعددة (الاستثمارات، المملوكة، مسودات...).
- **Flutter:** لا توجد صفحة إدارة تفصيلية؛ يوجد عرض عام للمشاريع فقط.
- **ملفات مرجعية:**  
  - Web: `sharkstage/app/(dashboard)/account/projects`.  
  - Flutter: لا يوجد ما يقابلها حتى الآن (يمكن إضافتها تحت `lib/screens/projects_management/` مثلاً).
- **التنفيذ:**  
  - إنشاء شاشة Project Management بفلترة حسب الدور (Owner/Investor).  
  - إعادة استخدام عناصر ProjectCard الجديدة وربطها بإجراءات (تعديل، عرض التفاصيل، تقديم عرض...).

## 4. العروض والرسائل (Offers & Messaging)
- **الويب:** نظام متكامل لإرسال عروض الاستثمار، رسائل، ومتابعة المحادثات.
- **Flutter:** لا يوجد إلا Chatbot.
- **ملفات مرجعية:**  
  - Web: `sharkstage/app/chat`, `sharkstage/app/(dashboard)/account/offers`.  
  - Flutter: `lib/screens/chatbot/chatbot_screen.dart` فقط.
- **المطلوب:**  
  - شاشات inbox / offers، عرض المحادثات، إرسال رسائل.  
  - تكامل مع endpoints الخاصة بـ offers/chat.

## 5. تحرير/تعديل المشروع
- **الويب:** صفحة Edit Project مع إعادة رفع صورة، تعديل الحقول، حذف المشروع.
- **Flutter:** لا يوجد تدفق تعديل.
- **ملفات مرجعية:**  
  - Web: `sharkstage/app/(dashboard)/account/projects/edit/[id]/page.jsx`.  
  - Flutter: يمكن إعادة استخدام `lib/widgets/project_form.dart` بعد التهيئة لوضع التعديل.
- **مطلوب:** شاشة تعديل تعيد استخدام ProjectForm مع ملء القيم الحالية وإرسال PATCH/PUT.

## 6. تدفق المصادقة (Auth Flow)
- **الويب:** OAuth (Google)، Cookies، إدارة جلسة مشتركة.
- **Flutter:** يعتمد على التخزين المحلي والـ token، والتحقق من Google Sign-In غير مكتمل.
- **ملفات مرجعية:**  
  - Web: `sharkstage/app/(auth)`, `sharkstage/lib/features/auth`.  
  - Flutter: `lib/screens/login`, `lib/services/auth_storage.dart`, `lib/controllers/auth..`.
- **توصيات:**  
  - توحيد مصدر الصلاحيات (دعم Google Sign-In).  
  - معالجة تجديد الجلسة/تحديث الـ token مثل الويب.

## 7. التحديثات الحية (Realtime Updates)
- **الويب:** بعض العناصر تظهر تحديثات مستمرة (notifications، offers، dashboard).
- **Flutter:** يعتمد على Refresh يدوي.
- **ملفات مرجعية:**  
  - Web: تحقق من استخدام sockets أو polling داخل `useDashboardProjects` وملفات offers/chat.  
  - Flutter: `DashboardController`، وشاشات dashboard الحالية.
- **الخطوات:**  
  - ربط التطبيق بـ WebSockets أو polling دوري للأقسام الحرجة.  
  - تحديث UI تلقائيًا عند وصول أحداث جديدة.

## 8. إدارة الملفات والمرفقات
- **الويب:** يسمح برفع مستندات متعددة (PDF/XLSX) مع المشروع.
- **Flutter:** حالياً يرفع صورة فقط (متوافق مع قيود السيرفر الحالية “image only”).
- **ملفات مرجعية:**  
  - Web: `sharkstage/app/(dashboard)/account/projects/add/page.jsx` + API المساعدة.  
  - Flutter: `lib/controllers/project_controlller.dart`.
- **المستقبل:**  
  - إذا سمح السيرفر مستقبلاً، إضافة حقل مرفقات متعددة مع التحقق من أنواع الملفات.

## 9. الملف الشخصي والإعدادات
- **الويب:** صفحة إعدادات قوية (تغيير بيانات، صورة شخصية، أمن الحساب…).
- **Flutter:** توجد شاشة إعدادات مختصرة، لا تشمل كل الحقول.
- **ملفات مرجعية:**  
  - Web: `sharkstage/app/(dashboard)/account/profile`, `.../settings`.  
  - Flutter: `lib/screens/profile`, `lib/screens/settings_screen`.
- **المطلوب:**  
  - جلب الحقول المتقدمة من الواجهة الخلفية.  
  - إضافة واجهات لتعديل البيانات وتحديث الصورة الشخصية/كلمة المرور.

## 10. تحسينات التصميم والتجربة البصرية
- **الويب:** تصميم Tailwind غني بالحركات (Hover, transitions, badges).
- **Flutter:** تصميم بسيط دون حالات hover أو animations المطولة.
- **ملفات مرجعية:**  
  - Web: `sharkstage/app/components`.  
  - Flutter: مختلف الـ widgets ضمن `lib/widgets`.
- **الاقتراح:**  
  - إضافة أنماط رسومية وتدرجات وحركات مشابهة، مع مراعاة خصوصية الموبايل.

---
### ملاحظات عامة
- التركيز المبدئي يفضل أن يكون على البنود 1-5 لأنها تؤثر مباشرةً على تجربة المستخدم الأساسية.
- كل بند يمكن تتبعه في تذاكر منفصلة مع ربطه بالـ API أو الملفات ذات الصلة (أرفقنا المسارات عند الحاجة).
- يوصى بإبقاء هذا المستند محدثًا عند إغلاق أي فجوة جديدة لضمان التساوي المستمر بين المنصتين.

