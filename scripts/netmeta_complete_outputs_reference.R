# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  الملف المرجعي الشامل والنهائي لجميع مخرجات جميع دوال مكتبة netmeta      ║
# ║  Complete Exhaustive Reference: ALL Outputs of ALL netmeta Functions       ║
# ║  Package Version: netmeta 3.7-0 (Rücker, Schwarzer et al.)               ║
# ║  Generated: 2026-09-21                                                     ║
# ║  تنسيق: شجرة هيكلية مع وصف عربي وإنجليزي لكل عنصر                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# ═══════════════════════════════════════════════════════════════════════════════
# فهرس الدوال (FUNCTION INDEX)
# ═══════════════════════════════════════════════════════════════════════════════
#
#   رقم │ الدالة              │ الوظيفة                                    │ عدد المخرجات
#  ─────┼─────────────────────┼────────────────────────────────────────────┼────────────
#    1  │ netmeta()           │ التحليل التجميعي الشبكي الأساسي            │ ~75+ عنصر
#    2  │ netrank()           │ ترتيب العلاجات (P-scores)                  │ ~25+ عنصر
#    3  │ netsplit()          │ تقسيم الأدلة المباشرة وغير المباشرة        │ ~35+ عنصر
#    4  │ netcomb()           │ التحليل الشبكي المكوّناتي (CNMA)           │ ~60+ عنصر
#    5  │ discomb()           │ CNMA لبيانات على مستوى الذراع              │ ~55+ عنصر
#    6  │ netleague()         │ جدول الدوري (League Table)                 │ ~10+ عنصر
#    7  │ netheat()           │ مخطط الحرارة الشبكي                        │ ~15+ عنصر
#    8  │ heatplot()          │ مخطط حراري للتناقض                         │ ~8+ عنصر
#    9  │ netgraph()          │ الرسم البياني للشبكة                       │ ~20+ عنصر
#   10  │ netmetabin()        │ تحليل شبكي للبيانات الثنائية               │ ~80+ عنصر
#   11  │ netmetareg()        │ الانحدار الوصفي الشبكي                     │ ~30+ عنصر
#   12  │ netbind()           │ دمج نتائج تحليلات شبكية متعددة             │ ~15+ عنصر
#   13  │ rankogram()         │ الرسم البياني لاحتمالات الترتيب            │ ~15+ عنصر
#   14  │ pairwise()          │ حساب المقارنات الزوجية                     │ ~15+ عمود
#   15  │ netconnection()     │ فحص اتصال الشبكة                           │ ~10+ عنصر
#   16  │ netcontrib()        │ مصفوفة المساهمة (Contribution Matrix)      │ ~15+ عنصر
#   17  │ netcomplex()        │ تقديرات التدخلات المعقدة                   │ ~10+ عنصر
#   18  │ netdistance()       │ مسافات الشبكة                              │ مصفوفة واحدة
#   19  │ netimpact()         │ تحليل التأثير                              │ ~10+ عنصر
#   20  │ netpairwise()       │ تحليل تجميعي زوجي لكل مقارنة               │ ~10+ عنصر
#   21  │ netposet()          │ الترتيب الجزئي (Partial Order / Hasse)     │ ~15+ عنصر
#   22  │ decomp.design()     │ تفكيك Q حسب التصميم                        │ ~10+ عنصر
#   23  │ netmeasures()       │ مقاييس تدفق الأدلة (Evidence Flow)         │ ~10+ عنصر
#   24  │ funnel.netmeta()    │ رسم القمع المعدّل                          │ ~8+ عنصر
#   25  │ forest.netmeta()    │ رسم الغابة الشبكي                          │ (رسم بياني)
#   26  │ subgroup.netmeta()  │ التحليل الشبكي حسب المجموعات الفرعية       │ ~20+ عنصر
#   27  │ nettable()          │ جدول نتائج مُنسّق                         │ مصفوفة
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  1. netmeta() — التحليل التجميعي الشبكي الأساسي                          █
# █     Core Frequentist Network Meta-Analysis (Graph-Theoretical)            █
# █     الاستدعاء: netmeta(TE, seTE, treat1, treat2, studlab, data, ...)     █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netmeta_object [List | Class: "netmeta" — ~75+ عنصر]
# │
# ├── 1.1 مصفوفات التقديرات الشاملة (Treatment Effect Matrices — N × N)
# │   │   ► N = عدد العلاجات. كل مصفوفة مربعة أبعادها [trts × trts]
# │   │   ► القيم على القطر = 0 (مقارنة العلاج بنفسه)
# │   │   ► TE[i,j] = أثر العلاج i مقارنة بالعلاج j (على مقياس log)
# │   │
# │   ├── TE.common              : matrix [N×N] — حجم الأثر بين كل زوج علاجات (نموذج الأثر المشترك Common Effect)
# │   ├── TE.fixed               : matrix [N×N] — (مرادف قديم لـ TE.common, للتوافقية العكسية)
# │   ├── TE.random              : matrix [N×N] — حجم الأثر بين كل زوج علاجات (نموذج الآثار العشوائية Random Effects)
# │   ├── seTE.common            : matrix [N×N] — الخطأ المعياري لكل مقارنة زوجية (Common)
# │   ├── seTE.fixed             : matrix [N×N] — (مرادف قديم لـ seTE.common)
# │   ├── seTE.random            : matrix [N×N] — الخطأ المعياري لكل مقارنة زوجية (Random)
# │   ├── lower.common           : matrix [N×N] — الحد الأدنى لفترة الثقة (Common)
# │   ├── lower.fixed            : matrix [N×N] — (مرادف قديم لـ lower.common)
# │   ├── lower.random           : matrix [N×N] — الحد الأدنى لفترة الثقة (Random)
# │   ├── upper.common           : matrix [N×N] — الحد الأعلى لفترة الثقة (Common)
# │   ├── upper.fixed            : matrix [N×N] — (مرادف قديم لـ upper.common)
# │   ├── upper.random           : matrix [N×N] — الحد الأعلى لفترة الثقة (Random)
# │   ├── statistic.common       : matrix [N×N] — إحصاء الاختبار z-score (Common)
# │   ├── statistic.fixed        : matrix [N×N] — (مرادف قديم)
# │   ├── statistic.random       : matrix [N×N] — إحصاء الاختبار z-score (Random)
# │   ├── pval.common            : matrix [N×N] — مستويات الدلالة الإحصائية p-values (Common)
# │   ├── pval.fixed             : matrix [N×N] — (مرادف قديم)
# │   ├── pval.random            : matrix [N×N] — مستويات الدلالة الإحصائية p-values (Random)
# │   ├── TE.direct.common       : matrix [N×N] — تقدير الأثر المباشر فقط (Common) — NA إذا لا يوجد دليل مباشر
# │   ├── TE.direct.random       : matrix [N×N] — تقدير الأثر المباشر فقط (Random) — NA إذا لا يوجد دليل مباشر
# │   ├── TE.indirect.common     : matrix [N×N] — تقدير الأثر غير المباشر فقط (Common)
# │   ├── TE.indirect.random     : matrix [N×N] — تقدير الأثر غير المباشر فقط (Random)
# │   ├── seTE.direct.common     : matrix [N×N] — الخطأ المعياري للأثر المباشر (Common)
# │   ├── seTE.direct.random     : matrix [N×N] — الخطأ المعياري للأثر المباشر (Random)
# │   ├── seTE.indirect.common   : matrix [N×N] — الخطأ المعياري للأثر غير المباشر (Common)
# │   ├── seTE.indirect.random   : matrix [N×N] — الخطأ المعياري للأثر غير المباشر (Random)
# │   ├── Cov.common             : matrix — مصفوفة التباين المشترك لتقديرات الأثر (Common)
# │   └── Cov.random             : matrix — مصفوفة التباين المشترك لتقديرات الأثر (Random)
# │
# ├── 1.2 تقديرات المقارنة مع العلاج المرجعي (Reference Group Comparisons)
# │   │   ► متجهات (Vectors) طولها N-1 (كل العلاجات عدا المرجع)
# │   │   ► تظهر فقط عند تحديد reference.group
# │   │
# │   ├── TE.ref.common          : named vector — أثر كل علاج مقارنة بالمرجع (Common)
# │   ├── TE.ref.fixed           : named vector — (مرادف قديم)
# │   ├── TE.ref.random          : named vector — أثر كل علاج مقارنة بالمرجع (Random)
# │   ├── seTE.ref.common        : named vector — الخطأ المعياري مقابل المرجع (Common)
# │   ├── seTE.ref.fixed         : named vector — (مرادف قديم)
# │   ├── seTE.ref.random        : named vector — الخطأ المعياري مقابل المرجع (Random)
# │   ├── lower.ref.common       : named vector — الحد الأدنى لـ CI مقابل المرجع (Common)
# │   ├── lower.ref.fixed        : named vector — (مرادف قديم)
# │   ├── lower.ref.random       : named vector — الحد الأدنى لـ CI مقابل المرجع (Random)
# │   ├── upper.ref.common       : named vector — الحد الأعلى لـ CI مقابل المرجع (Common)
# │   ├── upper.ref.fixed        : named vector — (مرادف قديم)
# │   ├── upper.ref.random       : named vector — الحد الأعلى لـ CI مقابل المرجع (Random)
# │   ├── statistic.ref.common   : named vector — إحصاء z مقابل المرجع (Common)
# │   ├── statistic.ref.fixed    : named vector — (مرادف قديم)
# │   ├── statistic.ref.random   : named vector — إحصاء z مقابل المرجع (Random)
# │   ├── pval.ref.common        : named vector — قيم p-value مقابل المرجع (Common)
# │   ├── pval.ref.fixed         : named vector — (مرادف قديم)
# │   ├── pval.ref.random        : named vector — قيم p-value مقابل المرجع (Random)
# │   └── reference.group        : character — اسم العلاج المرجعي المختار (مثل "Drug A")
# │
# ├── 1.3 إحصاءات عدم التجانس وعدم الاتساق (Heterogeneity & Inconsistency)
# │   │   ► Q الكلي = Q_heterogeneity + Q_inconsistency
# │   │   ► I² = (Q - df) / Q × 100%
# │   │
# │   ├── k                      : integer — إجمالي عدد الدراسات المضمنة
# │   ├── m                      : integer — إجمالي عدد المقارنات الزوجية المباشرة (الأضلاع)
# │   ├── n                      : integer — إجمالي عدد العلاجات / التدخلات (العقد)
# │   ├── d                      : integer — عدد تصاميم الدراسات الفريدة (مثل AB, ABC, ABD)
# │   ├── Q                      : numeric — إجمالي إحصاء كوشران Q (Total Cochran's Q)
# │   ├── df.Q                   : integer — درجات الحرية لإجمالي Q
# │   ├── pval.Q                 : numeric — الدلالة الإحصائية لإجمالي Q
# │   ├── Q.heterogeneity        : numeric — Q لعدم التجانس داخل التصاميم (Within-design heterogeneity)
# │   ├── df.Q.heterogeneity     : integer — درجات الحرية لعدم التجانس
# │   ├── pval.Q.heterogeneity   : numeric — القيمة الاحتمالية لعدم التجانس
# │   ├── Q.inconsistency        : numeric — Q لعدم الاتساق بين التصاميم (Between-design inconsistency)
# │   ├── df.Q.inconsistency     : integer — درجات الحرية لعدم الاتساق
# │   ├── pval.Q.inconsistency   : numeric — القيمة الاحتمالية لعدم الاتساق
# │   ├── I2                     : numeric — نسبة التباين الناتجة عن عدم التجانس (0 إلى 1)
# │   ├── lower.I2               : numeric — الحد الأدنى لفترة ثقة I²
# │   ├── upper.I2               : numeric — الحد الأعلى لفترة ثقة I²
# │   ├── tau2                   : numeric — تقدير التباين بين الدراسات (Between-study variance τ²)
# │   ├── se.tau2                : numeric — الخطأ المعياري لتقدير τ² (إن توفر)
# │   ├── lower.tau2             : numeric — الحد الأدنى لفترة ثقة τ²
# │   ├── upper.tau2             : numeric — الحد الأعلى لفترة ثقة τ²
# │   ├── tau                    : numeric — الانحراف المعياري بين الدراسات (√τ²)
# │   ├── lower.tau              : numeric — الحد الأدنى لفترة ثقة τ
# │   ├── upper.tau              : numeric — الحد الأعلى لفترة ثقة τ
# │   ├── method.tau             : character — طريقة تقدير τ² (مثل "DL", "REML", "PM", "ML")
# │   ├── method.tau.ci          : character — طريقة حساب فترة ثقة τ²
# │   ├── Q.decomp               : data.frame — جدول التفكيك الكامل لـ Q حسب التصميم
# │   │                             ► أعمدة: design, Q, df, pval
# │   ├── Q.het.design           : named vector — Q لعدم التجانس مُفكّك حسب كل تصميم
# │   └── Q.inc.detach           : data.frame — Q لعدم الاتساق عند فصل كل تصميم (Detachment)
# │
# ├── 1.4 مصفوفات نظرية المخططات والأوزان (Graph-Algebraic Network Matrices)
# │   │   ► مصفوفات جبر المخططات حسب نموذج Rücker (2012) الكهربائي
# │   │
# │   ├── A.matrix               : matrix — مصفوفة التجاور / التصميم (Edge-Design Adjacency Matrix)
# │   │                             ► أبعاد: [m × n] — الصفوف = المقارنات, الأعمدة = العلاجات
# │   ├── X.matrix               : matrix — مصفوفة التصميم الخطي الكامل (Full Design Matrix)
# │   │                             ► أبعاد: [m × (n-1)]
# │   ├── B.matrix               : matrix — مصفوفة الوقوع (Vertex-Edge Incidence Matrix)
# │   │                             ► أبعاد: [n × m]
# │   ├── L.matrix               : matrix — مصفوفة لابلاسيان الشبكة (Graph Laplacian)
# │   │                             ► أبعاد: [n × n] — مجموع كل صف/عمود = 0
# │   ├── Lplus.matrix           : matrix — مقلوب مور-بينروز لمصفوفة لابلاسيان (Moore-Penrose Pseudoinverse L⁺)
# │   │                             ► أبعاد: [n × n]
# │   ├── G.matrix               : matrix — مصفوفة جرين (Green's Matrix) — اللب الجبري للأوزان
# │   ├── H.matrix               : matrix — مصفوفة القبعة (Hat Matrix) — حصص الأدلة المباشرة
# │   │                             ► أبعاد: [m × m] — H[i,j] = مساهمة المقارنة j في تقدير المقارنة i
# │   ├── H.matrix.common        : matrix — مصفوفة القبعة للنموذج المشترك
# │   ├── H.matrix.random        : matrix — مصفوفة القبعة للنموذج العشوائي
# │   ├── P.matrix               : matrix — مصفوفة الإسقاط (Projection Matrix)
# │   ├── W.matrix               : matrix — مصفوفة الأوزان القطرية (Diagonal Weight Matrix)
# │   │                             ► أبعاد: [m × m] — قطرية, الأوزان = 1/seTE²
# │   ├── V.matrix               : matrix — مصفوفة التباين المشترك (Variance-Covariance Matrix)
# │   ├── n.matrix               : matrix [N×N] — عدد الدراسات التي تقارن مباشرة بين كل زوج علاجات
# │   ├── events.matrix          : matrix [N×N] — عدد الأحداث (إن وُجدت بيانات ثنائية)
# │   └── multiarm               : logical — هل توجد دراسات متعددة الأذرع في الشبكة؟
# │
# ├── 1.5 الترتيب والمقاييس المستخلصة (Ranking & Properties)
# │   │
# │   ├── Pscore.common          : named vector — درجات P-score لكل علاج (Common)
# │   ├── Pscore.fixed           : named vector — (مرادف قديم)
# │   ├── Pscore.random          : named vector — درجات P-score لكل علاج (Random)
# │   ├── trts                   : character vector — أسماء جميع العلاجات في الشبكة (مُرتبة أبجدياً)
# │   ├── studies                : character vector — أسماء/ملصقات الدراسات الفريدة
# │   ├── narms                  : named integer vector — عدد الأذرع في كل دراسة
# │   ├── designs                : character vector — التصاميم الفريدة (مثل "Drug A:Drug C")
# │   └── seq                    : character vector — ترتيب العلاجات المستخدم في العرض
# │
# ├── 1.6 بيانات الإدخال الأصلية (Input Data Vectors)
# │   │   ► المتجهات الأصلية كما أُدخلت للدالة (بعد الفرز)
# │   │
# │   ├── TE                     : numeric vector — أحجام الأثر المُدخلة (log-scale)
# │   ├── seTE                   : numeric vector — الأخطاء المعيارية المُدخلة
# │   ├── treat1                 : character vector — العلاج الأول في كل مقارنة
# │   ├── treat2                 : character vector — العلاج الثاني في كل مقارنة
# │   ├── studlab                : character vector — ملصقات الدراسات
# │   ├── data                   : data.frame — الإطار البياني الأصلي الممرر للدالة
# │   ├── TE.nma.common          : numeric vector — تقديرات NMA المجمعة لكل مقارنة مدخلة (Common)
# │   ├── TE.nma.random          : numeric vector — تقديرات NMA المجمعة لكل مقارنة مدخلة (Random)
# │   ├── leverage.common        : numeric vector — قيم الرافعة (Leverage) لكل مقارنة (Common)
# │   ├── leverage.random        : numeric vector — قيم الرافعة (Leverage) لكل مقارنة (Random)
# │   ├── residuals.common       : numeric vector — البواقي (Residuals) لكل مقارنة (Common)
# │   ├── residuals.random       : numeric vector — البواقي (Residuals) لكل مقارنة (Random)
# │   ├── w.common               : numeric vector — الأوزان الفعلية لكل مقارنة (Common)
# │   ├── w.random               : numeric vector — الأوزان الفعلية لكل مقارنة (Random)
# │   ├── Q.leverage              : numeric vector — مساهمة كل مقارنة في Q (قيم الرافعة)
# │   ├── order                  : integer vector — ترتيب الفرز الداخلي للمقارنات
# │   └── subset                 : logical/NULL — المجموعة الجزئية المستخدمة (إن وُجدت)
# │
# ├── 1.7 إعدادات النموذج ومعاملات الاستدعاء (Model Settings & Call Metadata)
# │   │
# │   ├── sm                     : character — المقياس الإحصائي للأثر ("HR", "OR", "RR", "MD", "SMD", "ROM")
# │   ├── level                  : numeric — مستوى الثقة الفردي (مثل 0.95)
# │   ├── level.ma               : numeric — مستوى الثقة للنتائج التجميعية
# │   ├── level.comb             : numeric — (مرادف قديم لـ level.ma)
# │   ├── common                 : logical — هل تم تفعيل النموذج المشترك؟ (TRUE/FALSE)
# │   ├── random                 : logical — هل تم تفعيل النموذج العشوائي؟ (TRUE/FALSE)
# │   ├── fixed                  : logical — (مرادف قديم لـ common)
# │   ├── prediction             : logical — هل تم حساب فترة التنبؤ؟
# │   ├── level.predict          : numeric — مستوى فترة التنبؤ
# │   ├── lower.predict          : matrix — الحد الأدنى لفترة التنبؤ
# │   ├── upper.predict          : matrix — الحد الأعلى لفترة التنبؤ
# │   ├── backtransf             : logical — التحويل العكسي (مثل exp() لـ log-HR)
# │   ├── tol.multiarm           : numeric — حد التسامح للدراسات متعددة الأذرع
# │   ├── tol.multiarm.se        : numeric — حد التسامح للخطأ المعياري في الدراسات متعددة الأذرع
# │   ├── details.chkmultiarm    : logical/data.frame — تقرير فحص الدراسات متعددة الأذرع
# │   ├── sep.trts               : character — الفاصل بين أسماء العلاجات (افتراضي ":")
# │   ├── nchar.trts             : integer/NULL — عدد الأحرف المستخدمة في اختصار أسماء العلاجات
# │   ├── call                   : call — الأمر البرمجي الأصلي لاستدعاء الدالة
# │   ├── title                  : character — عنوان التحليل (إن حُدد)
# │   └── version                : character — رقم إصدار حزمة netmeta
# │
# └── 1.8 مخرجات إضافية نادرة (Additional / Conditional Outputs)
#     │
#     ├── lower.predict.common   : matrix — الحد الأدنى لفترة التنبؤ (Common)
#     ├── upper.predict.common   : matrix — الحد الأعلى لفترة التنبؤ (Common)
#     ├── lower.predict.random   : matrix — الحد الأدنى لفترة التنبؤ (Random)
#     ├── upper.predict.random   : matrix — الحد الأعلى لفترة التنبؤ (Random)
#     ├── seTE.predict.common    : matrix — الخطأ المعياري لفترة التنبؤ (Common)
#     ├── seTE.predict.random    : matrix — الخطأ المعياري لفترة التنبؤ (Random)
#     ├── df.Q.b.w               : numeric — درجات الحرية لاختبار عدم التجانس بين/داخل
#     ├── text.common            : character — النص المعروض للنموذج المشترك
#     ├── text.random            : character — النص المعروض للنموذج العشوائي
#     ├── text.predict           : character — النص المعروض لفترة التنبؤ
#     ├── text.w.common          : character — نص الأوزان (Common)
#     ├── text.w.random          : character — نص الأوزان (Random)
#     ├── x$prop.direct.common   : matrix — نسبة الدليل المباشر لكل مقارنة (Common)
#     └── x$prop.direct.random   : matrix — نسبة الدليل المباشر لكل مقارنة (Random)
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  2. netrank() — ترتيب العلاجات (P-scores / SUCRA Analogue)               █
# █     Treatment Ranking via P-scores (Rücker & Schwarzer, 2015)             █
# █     الاستدعاء: netrank(x, small.values = "good", ...)                    █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netrank_object [List | Class: "netrank" — ~25 عنصر]
# │
# ├── 2.1 درجات الترتيب (Ranking Scores)
# │   │
# │   ├── ranking.common         : named numeric vector — P-scores لكل علاج (Common Effect)
# │   │                             ► القيمة 0-1: أعلى = أفضل أداءً
# │   ├── ranking.fixed          : named numeric vector — (مرادف قديم لـ ranking.common)
# │   ├── ranking.random         : named numeric vector — P-scores لكل علاج (Random Effects)
# │   ├── Pscore.common          : named numeric vector — (نسخة من ranking.common)
# │   ├── Pscore.fixed           : named numeric vector — (مرادف قديم)
# │   └── Pscore.random          : named numeric vector — (نسخة من ranking.random)
# │
# ├── 2.2 مصفوفة الأفضلية الزوجية (Pairwise Preference Matrix)
# │   │
# │   ├── Pmatrix.common         : matrix [N×N] — P(i أفضل من j) لكل زوج علاجات (Common)
# │   │                             ► القيمة 0-1: احتمال أن العلاج i أفضل من j
# │   │                             ► P[i,j] + P[j,i] = 1 دائماً
# │   ├── Pmatrix.fixed          : matrix [N×N] — (مرادف قديم)
# │   └── Pmatrix.random         : matrix [N×N] — P(i أفضل من j) لكل زوج (Random)
# │
# ├── 2.3 إعدادات وبيانات وصفية (Settings & Metadata)
# │   │
# │   ├── small.values           : character — اتجاه الأفضلية ("good" = القيم الصغيرة أفضل, "bad" = القيم الكبيرة أفضل)
# │   │                             ► "good": HR < 1 = أفضل (نسبة المخاطر)
# │   │                             ► "bad":  OR > 1 = أفضل (نادر)
# │   │                             ► "desirable": مرادف لـ "bad"
# │   │                             ► "undesirable": مرادف لـ "good"
# │   ├── common                 : logical — هل النموذج المشترك مُفعّل؟
# │   ├── random                 : logical — هل النموذج العشوائي مُفعّل؟
# │   ├── fixed                  : logical — (مرادف قديم)
# │   ├── sm                     : character — المقياس الإحصائي (موروث من netmeta)
# │   ├── trts                   : character vector — أسماء العلاجات
# │   ├── x                      : netmeta object — كائن netmeta الأصلي المُمرر
# │   ├── version                : character — إصدار الحزمة
# │   └── call                   : call — الأمر البرمجي الأصلي
# │
# └── 2.4 مخرجات إضافية
#     │
#     ├── sort.common            : data.frame — ترتيب العلاجات حسب P-score (Common, تنازلي)
#     ├── sort.random            : data.frame — ترتيب العلاجات حسب P-score (Random, تنازلي)
#     ├── text.common            : character — نص العرض للنموذج المشترك
#     └── text.random            : character — نص العرض للنموذج العشوائي
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  3. netsplit() — تقسيم الأدلة المباشرة وغير المباشرة                     █
# █     Split Direct vs. Indirect Evidence (Dias et al., 2010)                █
# █     الاستدعاء: netsplit(x, method = "Back-calculation", ...)              █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netsplit_object [List | Class: "netsplit" — ~35+ عنصر]
# │
# ├── 3.1 الأدلة المباشرة (Direct Evidence)
# │   │   ► متجهات بطول = عدد المقارنات الزوجية الممكنة
# │   │
# │   ├── TE.direct.common       : numeric vector — تقدير الأثر المباشر (Common)
# │   ├── TE.direct.fixed        : numeric vector — (مرادف قديم)
# │   ├── TE.direct.random       : numeric vector — تقدير الأثر المباشر (Random)
# │   ├── seTE.direct.common     : numeric vector — الخطأ المعياري للأثر المباشر (Common)
# │   ├── seTE.direct.fixed      : numeric vector — (مرادف قديم)
# │   ├── seTE.direct.random     : numeric vector — الخطأ المعياري للأثر المباشر (Random)
# │   ├── lower.direct.common    : numeric vector — الحد الأدنى لـ CI المباشر (Common)
# │   ├── upper.direct.common    : numeric vector — الحد الأعلى لـ CI المباشر (Common)
# │   ├── lower.direct.random    : numeric vector — الحد الأدنى لـ CI المباشر (Random)
# │   ├── upper.direct.random    : numeric vector — الحد الأعلى لـ CI المباشر (Random)
# │   ├── statistic.direct.common: numeric vector — إحصاء z للأثر المباشر (Common)
# │   ├── statistic.direct.random: numeric vector — إحصاء z للأثر المباشر (Random)
# │   ├── pval.direct.common     : numeric vector — p-value للأثر المباشر (Common)
# │   └── pval.direct.random     : numeric vector — p-value للأثر المباشر (Random)
# │
# ├── 3.2 الأدلة غير المباشرة (Indirect Evidence)
# │   │
# │   ├── TE.indirect.common     : numeric vector — تقدير الأثر غير المباشر (Common)
# │   ├── TE.indirect.fixed      : numeric vector — (مرادف قديم)
# │   ├── TE.indirect.random     : numeric vector — تقدير الأثر غير المباشر (Random)
# │   ├── seTE.indirect.common   : numeric vector — الخطأ المعياري (Common)
# │   ├── seTE.indirect.fixed    : numeric vector — (مرادف قديم)
# │   ├── seTE.indirect.random   : numeric vector — الخطأ المعياري (Random)
# │   ├── lower.indirect.common  : numeric vector — الحد الأدنى لـ CI (Common)
# │   ├── upper.indirect.common  : numeric vector — الحد الأعلى لـ CI (Common)
# │   ├── lower.indirect.random  : numeric vector — الحد الأدنى لـ CI (Random)
# │   ├── upper.indirect.random  : numeric vector — الحد الأعلى لـ CI (Random)
# │   ├── statistic.indirect.common : numeric vector — إحصاء z (Common)
# │   ├── statistic.indirect.random : numeric vector — إحصاء z (Random)
# │   ├── pval.indirect.common   : numeric vector — p-value (Common)
# │   └── pval.indirect.random   : numeric vector — p-value (Random)
# │
# ├── 3.3 تقديرات الشبكة المُجمعة (Network Estimates)
# │   │
# │   ├── TE.common              : numeric vector — تقدير NMA المُجمع (Common)
# │   ├── TE.random              : numeric vector — تقدير NMA المُجمع (Random)
# │   ├── seTE.common            : numeric vector — الخطأ المعياري NMA (Common)
# │   ├── seTE.random            : numeric vector — الخطأ المعياري NMA (Random)
# │   ├── lower.common           : numeric vector — حد أدنى CI (Common)
# │   ├── upper.common           : numeric vector — حد أعلى CI (Common)
# │   ├── lower.random           : numeric vector — حد أدنى CI (Random)
# │   └── upper.random           : numeric vector — حد أعلى CI (Random)
# │
# ├── 3.4 اختبار الاتساق / التناقض (Consistency / Incoherence Test)
# │   │   ► اختبار z لكل مقارنة: H0: أثر مباشر = أثر غير مباشر
# │   │
# │   ├── compare.common         : data.frame — نتائج المقارنة بين المباشر وغير المباشر (Common)
# │   │                             ► أعمدة: comparison, TE.diff, seTE.diff, z, p
# │   ├── compare.fixed          : data.frame — (مرادف قديم)
# │   ├── compare.random         : data.frame — نتائج المقارنة (Random)
# │   ├── TE.diff.common         : numeric vector — الفرق بين المباشر وغير المباشر (Common)
# │   ├── TE.diff.random         : numeric vector — الفرق بين المباشر وغير المباشر (Random)
# │   ├── seTE.diff.common       : numeric vector — الخطأ المعياري للفرق (Common)
# │   ├── seTE.diff.random       : numeric vector — الخطأ المعياري للفرق (Random)
# │   ├── statistic.diff.common  : numeric vector — إحصاء z للفرق (Common)
# │   ├── statistic.diff.random  : numeric vector — إحصاء z للفرق (Random)
# │   ├── pval.diff.common       : numeric vector — p-value للتناقض (Common)
# │   │                             ► p < 0.05 يشير إلى تناقض (Incoherence)
# │   └── pval.diff.random       : numeric vector — p-value للتناقض (Random)
# │
# ├── 3.5 نسبة الأدلة (Proportion of Evidence)
# │   │
# │   ├── prop.direct.common     : numeric vector — نسبة الدليل المباشر (0-1) (Common)
# │   └── prop.direct.random     : numeric vector — نسبة الدليل المباشر (0-1) (Random)
# │
# └── 3.6 بيانات وصفية (Metadata)
#     │
#     ├── comparison             : character vector — أسماء المقارنات (مثل "Drug C:Drug A")
#     ├── treat1                 : character vector — العلاج الأول
#     ├── treat2                 : character vector — العلاج الثاني
#     ├── k                      : integer vector — عدد الدراسات لكل مقارنة مباشرة
#     ├── method                 : character — طريقة الحساب ("Back-calculation", "SIDDE", "Graph-theoretical")
#     ├── sm                     : character — المقياس الإحصائي
#     ├── x                      : netmeta object — الكائن الأصلي
#     └── version                : character — إصدار الحزمة
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  4. netcomb() — التحليل الشبكي المكوّناتي (Component NMA)                █
# █     Additive Component Network Meta-Analysis (Rücker et al., 2020)        █
# █     الاستدعاء: netcomb(x, inactive = NULL, ...)                           █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netcomb_object [List | Class: "netcomb" — ~60+ عنصر]
# │
# ├── 4.1 تقديرات أثر المكونات الفردية (Individual Component Effects)
# │   │   ► C = عدد المكونات النشطة (بدون المرجع غير النشط)
# │   │
# │   ├── Comp.common            : named numeric vector [C] — أثر كل مكوّن إضافي (Common, على مقياس log)
# │   ├── Comp.fixed             : named numeric vector [C] — (مرادف قديم)
# │   ├── Comp.random            : named numeric vector [C] — أثر كل مكوّن إضافي (Random)
# │   ├── seComp.common          : named numeric vector [C] — الخطأ المعياري لكل مكوّن (Common)
# │   ├── seComp.fixed           : named numeric vector [C] — (مرادف قديم)
# │   ├── seComp.random          : named numeric vector [C] — الخطأ المعياري لكل مكوّن (Random)
# │   ├── lower.Comp.common      : named numeric vector [C] — حد أدنى CI لكل مكوّن (Common)
# │   ├── lower.Comp.fixed       : named numeric vector [C] — (مرادف قديم)
# │   ├── lower.Comp.random      : named numeric vector [C] — حد أدنى CI لكل مكوّن (Random)
# │   ├── upper.Comp.common      : named numeric vector [C] — حد أعلى CI (Common)
# │   ├── upper.Comp.fixed       : named numeric vector [C] — (مرادف قديم)
# │   ├── upper.Comp.random      : named numeric vector [C] — حد أعلى CI (Random)
# │   ├── statistic.Comp.common  : named numeric vector [C] — إحصاء z لكل مكوّن (Common)
# │   ├── statistic.Comp.fixed   : named numeric vector [C] — (مرادف قديم)
# │   ├── statistic.Comp.random  : named numeric vector [C] — إحصاء z لكل مكوّن (Random)
# │   ├── pval.Comp.common       : named numeric vector [C] — p-value لكل مكوّن (Common)
# │   ├── pval.Comp.fixed        : named numeric vector [C] — (مرادف قديم)
# │   └── pval.Comp.random       : named numeric vector [C] — p-value لكل مكوّن (Random)
# │
# ├── 4.2 مصفوفات تقديرات التوليفات العلاجية (Combination Treatment Effect Matrices)
# │   │   ► نفس بنية مصفوفات netmeta() [N×N] ولكن تحت النموذج الجمعي
# │   │
# │   ├── TE.common              : matrix [N×N] — أثر التوليفة (Common, نموذج جمعي)
# │   ├── TE.random              : matrix [N×N] — أثر التوليفة (Random, نموذج جمعي)
# │   ├── seTE.common            : matrix [N×N] — الخطأ المعياري (Common)
# │   ├── seTE.random            : matrix [N×N] — الخطأ المعياري (Random)
# │   ├── lower.common           : matrix [N×N] — حد أدنى CI (Common)
# │   ├── upper.common           : matrix [N×N] — حد أعلى CI (Common)
# │   ├── lower.random           : matrix [N×N] — حد أدنى CI (Random)
# │   ├── upper.random           : matrix [N×N] — حد أعلى CI (Random)
# │   ├── statistic.common       : matrix [N×N] — إحصاء z (Common)
# │   ├── statistic.random       : matrix [N×N] — إحصاء z (Random)
# │   ├── pval.common            : matrix [N×N] — p-values (Common)
# │   └── pval.random            : matrix [N×N] — p-values (Random)
# │
# ├── 4.3 إحصاءات جودة ملاءمة النموذج الجمعي (Additive Model Goodness-of-Fit)
# │   │   ► مقارنة بين النموذج الشبكي القياسي والنموذج الجمعي
# │   │
# │   ├── Q.additive             : numeric — Q للنموذج الجمعي (Additive model Q)
# │   ├── df.Q.additive          : integer — درجات الحرية للنموذج الجمعي
# │   ├── pval.Q.additive        : numeric — p-value للنموذج الجمعي
# │   ├── Q.standard             : numeric — Q للنموذج الشبكي القياسي (Standard NMA Q)
# │   ├── df.Q.standard          : integer — درجات الحرية للنموذج القياسي
# │   ├── pval.Q.standard        : numeric — p-value للنموذج القياسي
# │   ├── Q.diff                 : numeric — الفرق في Q بين النموذجين (Q_additive - Q_standard)
# │   │                             ► Q.diff كبير = النموذج الجمعي لا يناسب → تأثيرات تفاعلية
# │   ├── df.Q.diff              : integer — درجات الحرية للفرق
# │   ├── pval.Q.diff            : numeric — p-value للفرق
# │   │                             ► p > 0.05 = النموذج الجمعي مقبول (لا تفاعلات)
# │   ├── Q.heterogeneity        : numeric — Q لعدم التجانس
# │   ├── df.Q.heterogeneity     : integer — درجات الحرية
# │   ├── pval.Q.heterogeneity   : numeric — p-value
# │   ├── Q.inconsistency        : numeric — Q لعدم الاتساق
# │   ├── df.Q.inconsistency     : integer — درجات الحرية
# │   └── pval.Q.inconsistency   : numeric — p-value
# │
# ├── 4.4 بيانات المكونات (Component Information)
# │   │
# │   ├── comps                  : character vector — أسماء المكونات النشطة (مثل "Component B", "Component C", "Component D")
# │   ├── inactive               : character — اسم المكوّن غير النشط / المرجع (مثل "Component A")
# │   ├── C.matrix               : matrix — مصفوفة تحليل المكونات (Component Decomposition Matrix)
# │   │                             ► أبعاد: [N × C] — تحليل كل علاج إلى مكوناته
# │   ├── trts                   : character vector — أسماء العلاجات
# │   ├── n                      : integer — عدد العلاجات
# │   └── n.comps                : integer — عدد المكونات النشطة
# │
# ├── 4.5 التباين والإعدادات (Heterogeneity & Settings)
# │   │
# │   ├── tau2                   : numeric — التباين بين الدراسات (τ²)
# │   ├── tau                    : numeric — الانحراف المعياري (τ)
# │   ├── I2                     : numeric — I²
# │   ├── sm                     : character — المقياس الإحصائي
# │   ├── common                 : logical — النموذج المشترك مُفعّل؟
# │   ├── random                 : logical — النموذج العشوائي مُفعّل؟
# │   ├── reference.group        : character — العلاج المرجعي
# │   ├── x                      : netmeta object — كائن netmeta الأصلي
# │   └── version                : character — إصدار الحزمة
# │
# └── 4.6 مخرجات إضافية للتوليفات (Combination-Specific Outputs)
#     │
#     ├── TE.ref.common          : named vector — أثر كل توليفة مقابل المرجع (Common)
#     ├── TE.ref.random          : named vector — أثر كل توليفة مقابل المرجع (Random)
#     ├── seTE.ref.common        : named vector — الخطأ المعياري (Common)
#     ├── seTE.ref.random        : named vector — الخطأ المعياري (Random)
#     ├── lower.ref.common       : named vector — حد أدنى CI (Common)
#     ├── upper.ref.common       : named vector — حد أعلى CI (Common)
#     ├── lower.ref.random       : named vector — حد أدنى CI (Random)
#     ├── upper.ref.random       : named vector — حد أعلى CI (Random)
#     ├── pval.ref.common        : named vector — p-value (Common)
#     └── pval.ref.random        : named vector — p-value (Random)
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  5. discomb() — التحليل المكوّناتي للبيانات على مستوى الذراع              █
# █     Disconnected Component NMA (Arm-Level Data)                           █
# █     الاستدعاء: discomb(TE, seTE, treat1, treat2, studlab, ...,            █
# █                        inactive = NULL)                                    █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# discomb_object [List | Class: "discomb" — ~55+ عنصر]
# │
# ├── ► نفس بنية netcomb() تقريباً ولكن يقبل شبكات غير متصلة (Disconnected Networks)
# │
# ├── 5.1 تقديرات المكونات
# │   ├── (جميع عناصر القسم 4.1 من netcomb: Comp.common/random, seComp.*, lower.Comp.*, upper.Comp.*, إلخ)
# │
# ├── 5.2 مصفوفات التوليفات
# │   ├── (جميع عناصر القسم 4.2 من netcomb: TE.common/random, seTE.*, lower.*, upper.*, إلخ)
# │
# ├── 5.3 إحصاءات جودة الملاءمة
# │   ├── (جميع عناصر القسم 4.3: Q.additive, Q.standard, Q.diff, إلخ)
# │
# ├── 5.4 بيانات الشبكات الفرعية (Subnetwork Information)
# │   │
# │   ├── subnet                 : integer vector — رقم الشبكة الفرعية لكل دراسة
# │   ├── n.subnets              : integer — عدد الشبكات الفرعية المنفصلة
# │   ├── subnet.comparisons     : list — المقارنات في كل شبكة فرعية
# │   └── sep.comps              : character — الفاصل بين أسماء المكونات (افتراضي "+")
# │
# └── 5.5 بيانات الإدخال والإعدادات
#     ├── (نفس عناصر القسم 4.4 و 4.5 من netcomb)
#     ├── TE                     : numeric vector — أحجام الأثر المُدخلة
#     ├── seTE                   : numeric vector — الأخطاء المعيارية
#     ├── treat1                 : character vector — العلاج الأول
#     ├── treat2                 : character vector — العلاج الثاني
#     └── studlab                : character vector — ملصقات الدراسات
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  6. netleague() — جدول الدوري (League Table)                             █
# █     Pairwise Comparison League Table Matrix                               █
# █     الاستدعاء: netleague(x, common = x$common, random = x$random, ...)   █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netleague_object [List | Class: "netleague" — ~10+ عنصر]
# │
# ├── 6.1 مصفوفات الجدول (League Table Matrices)
# │   │   ► مصفوفات نصية (Character Matrices) بتنسيق "HR [CI_low; CI_up]"
# │   │   ► المثلث السفلي = نموذج, المثلث العلوي = نموذج آخر
# │   │
# │   ├── common                 : character matrix [N×N] — جدول الدوري (Common Effect)
# │   │                             ► cell[i,j] = "0.65 [0.52; 0.81]" (مثال)
# │   │                             ► القطر = أسماء العلاجات
# │   ├── fixed                  : character matrix [N×N] — (مرادف قديم)
# │   ├── random                 : character matrix [N×N] — جدول الدوري (Random Effects)
# │   ├── direct                 : character matrix [N×N] — جدول الأدلة المباشرة فقط
# │   └── indirect               : character matrix [N×N] — جدول الأدلة غير المباشرة فقط (إن طُلب)
# │
# ├── 6.2 الترتيب والإعدادات (Order & Settings)
# │   │
# │   ├── seq                    : character vector — ترتيب العلاجات في الجدول (من الأفضل للأسوأ)
# │   ├── ci                     : logical — هل تم تضمين فترة الثقة؟
# │   ├── backtransf             : logical — هل تم التحويل العكسي (مثل exp(log-HR))؟
# │   ├── digits                 : integer — عدد الأرقام العشرية
# │   ├── big.mark               : character — فاصل الآلاف
# │   ├── text.NA                : character — النص المعروض للقيم المفقودة
# │   ├── sm                     : character — المقياس الإحصائي
# │   ├── x                      : netmeta object — الكائن الأصلي
# │   ├── bracket                : character — نوع الأقواس ("[", "(")
# │   ├── separator              : character — الفاصل داخل CI ("; ", " to ")
# │   └── version                : character — إصدار الحزمة
# │
# └── 6.3 مصفوفات رقمية خام (Raw Numeric Matrices — إن طُلبت)
#     │
#     ├── TE.common              : numeric matrix [N×N] — القيم الرقمية الخام (Common)
#     ├── TE.random              : numeric matrix [N×N] — القيم الرقمية الخام (Random)
#     ├── lower.common           : numeric matrix [N×N] — حدود CI الدنيا (Common)
#     ├── upper.common           : numeric matrix [N×N] — حدود CI العليا (Common)
#     ├── lower.random           : numeric matrix [N×N] — حدود CI الدنيا (Random)
#     └── upper.random           : numeric matrix [N×N] — حدود CI العليا (Random)
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  7. netheat() — مخطط الحرارة الشبكي وتفكيك Q                             █
# █     Net Heat Plot & Design-Based Q Decomposition (Krahn et al., 2013)     █
# █     الاستدعاء: netheat(x, random = FALSE, ...)                            █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netheat_object [List (غير مرئي) | يُرجع بيانات الرسم — ~15+ عنصر]
# │
# ├── 7.1 مصفوفات التفكيك (Decomposition Matrices)
# │   │
# │   ├── net.heat.matrix        : matrix [D×D] — مصفوفة الحرارة الشبكية
# │   │                             ► D = عدد التصاميم
# │   │                             ► cell[i,j] = مساهمة التصميم j في عدم اتساق التصميم i
# │   ├── Q.decomp.design        : numeric vector — Q مُفكّك حسب التصميم
# │   ├── Q.design               : data.frame — جدول تفكيك Q الكامل حسب التصاميم
# │   │                             ► أعمدة: design, Q, df, pval
# │   ├── residuals              : matrix — مصفوفة البواقي المعيارية
# │   └── hatmatrix              : matrix — مصفوفة القبعة (Hat matrix)
# │
# ├── 7.2 بيانات التلوين والعرض (Coloring & Display Data)
# │   │
# │   ├── design                 : character vector — أسماء التصاميم
# │   ├── tau2                   : numeric — τ² المستخدم في الحساب
# │   └── random                 : logical — هل استُخدم النموذج العشوائي؟
# │
# └── 7.3 ► ملاحظة: netheat() ينتج رسماً بيانياً مباشرة + يُرجع البيانات بشكل غير مرئي (invisible)
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  8. heatplot() — مخطط حراري مُحسّن للتناقض                               █
# █     Enhanced Heat Plot for Inconsistency (Newer Implementation)           █
# █     الاستدعاء: heatplot(x, ...)                                           █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# heatplot_output [Invisible Return — ~8+ عنصر]
# │
# ├── 8.1 بيانات المخطط
# │   │
# │   ├── order                  : character vector — ترتيب العلاجات في المخطط
# │   ├── matrix.common          : matrix — مصفوفة القيم المعروضة (Common)
# │   ├── matrix.random          : matrix — مصفوفة القيم المعروضة (Random)
# │   └── z.colors               : matrix — مصفوفة الألوان المُحسوبة
# │
# └── 8.2 ► الإخراج الرئيسي هو رسم بياني حراري مباشر
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  9. netgraph() — الرسم البياني للشبكة                                    █
# █     Automated Network Graph Drawing (Rücker & Schwarzer, 2016)           █
# █     الاستدعاء: netgraph(x, start.layout = "circle", ...)                 █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netgraph_output [Invisible list — ~20+ عنصر]
# │
# ├── 9.1 إحداثيات العقد (Node Coordinates)
# │   │
# │   ├── nodes                  : data.frame — إحداثيات العقد (العلاجات)
# │   │                             ► أعمدة: labels, xpos, ypos, number
# │   ├── xpos                   : numeric vector — الإحداثيات الأفقية لكل عقدة
# │   └── ypos                   : numeric vector — الإحداثيات الرأسية لكل عقدة
# │
# ├── 9.2 خصائص العقد (Node Properties)
# │   │
# │   ├── labels                 : character vector — تسميات العقد (أسماء العلاجات)
# │   ├── number.of.studies      : named integer vector — عدد الدراسات المتصلة بكل عقدة
# │   ├── cex.points             : numeric vector — حجم كل عقدة (يتناسب مع عدد الدراسات)
# │   ├── col.points             : character vector — لون كل عقدة
# │   ├── pch.points             : integer vector — رمز كل عقدة
# │   └── adj                    : numeric vector — محاذاة التسمية لكل عقدة
# │
# ├── 9.3 خصائص الأضلاع (Edge Properties)
# │   │
# │   ├── edges                  : data.frame — بيانات الأضلاع (المقارنات المباشرة)
# │   │                             ► أعمدة: treat1, treat2, n.studies, TE, thickness
# │   ├── number.of.studies.edges: integer vector — عدد الدراسات لكل ضلع
# │   ├── lwd                    : numeric vector — سُمك كل ضلع (يتناسب مع عدد الدراسات)
# │   ├── col.lines              : character vector — لون كل ضلع
# │   └── lty                    : integer vector — نمط خط كل ضلع
# │
# ├── 9.4 التخطيط (Layout Information)
# │   │
# │   ├── start.layout           : character — التخطيط المبدئي ("circle", "bipartite", "star")
# │   ├── iterate                : logical — هل تم التكرار التحسيني (Stress Minimization)؟
# │   └── dim                    : character — البُعد ("2d", "3d")
# │
# └── 9.5 ► الإخراج الرئيسي: رسم بياني شبكي
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  10. netmetabin() — التحليل الشبكي للبيانات الثنائية                     █
# █      Binary NMA (Mantel-Haenszel / NCH / Penalised Logistic Regression)  █
# █      الاستدعاء: netmetabin(event1, n1, event2, n2, treat1, treat2, ...)  █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netmetabin_object [List | Class: "netmetabin", "netmeta" — ~80+ عنصر]
# │
# ├── ► يرث جميع مخرجات netmeta() (القسم 1 بالكامل) بالإضافة إلى:
# │
# ├── 10.1 بيانات ثنائية إضافية (Binary-Specific Data)
# │   │
# │   ├── event1                 : integer vector — عدد الأحداث في مجموعة العلاج 1
# │   ├── n1                     : integer vector — حجم العينة في مجموعة العلاج 1
# │   ├── event2                 : integer vector — عدد الأحداث في مجموعة العلاج 2
# │   ├── n2                     : integer vector — حجم العينة في مجموعة العلاج 2
# │   ├── incr                   : numeric — تصحيح الاستمرارية (Continuity Correction) المُضاف
# │   ├── allincr                : logical — هل أُضيف التصحيح لجميع الدراسات؟
# │   ├── addincr                : logical — هل أُضيف التصحيح بشكل إضافي؟
# │   ├── cc.pooled              : logical — هل استُخدم التصحيح المُجمع؟
# │   ├── method                 : character — الطريقة ("MH", "Inverse", "NCH", "PLR")
# │   │                             ► "MH" = Mantel-Haenszel
# │   │                             ► "NCH" = Non-Central Hypergeometric
# │   │                             ► "PLR" = Penalised Logistic Regression
# │   ├── events.common          : matrix [N×N] — مصفوفة الأحداث المُجمعة (Common)
# │   ├── events.random          : matrix [N×N] — مصفوفة الأحداث المُجمعة (Random)
# │   ├── n.events               : named integer vector — إجمالي الأحداث لكل علاج
# │   ├── n.patients             : named integer vector — إجمالي المرضى لكل علاج
# │   ├── allstudies             : logical — هل شُملت جميع الدراسات بما فيها ذات الأحداث الصفرية؟
# │   ├── doublezeros            : logical — هل شُملت الدراسات ذات الأحداث الصفرية المزدوجة؟
# │   └── model.glm              : glm object — كائن الانحدار اللوجستي المُعاقَب (فقط لطريقة PLR)
# │
# └── 10.2 ► جميع مخرجات netmeta() الأخرى (الأقسام 1.1 إلى 1.8)
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  11. netmetareg() — الانحدار الوصفي الشبكي                               █
# █      Network Meta-Regression (Kwarteng et al., 2026)                      █
# █      الاستدعاء: netmetareg(x, covar, assumption = "common", ...)          █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netmetareg_object [List | Class: "rma.uni" (metafor) + "netmetareg" — ~30+ عنصر]
# │
# ├── 11.1 معاملات الانحدار (Regression Coefficients)
# │   │   ► يعتمد على assumption: "common" = ميل واحد لكل المقارنات
# │   │                           "independent" = ميل مستقل لكل مقارنة
# │   │
# │   ├── b                      : numeric vector — معاملات الانحدار (Intercept + Slope(s))
# │   │                             ► b[1] = القاطع (Intercept)
# │   │                             ► b[2] = ميل المتغير المشترك (Covariate Slope)
# │   ├── se                     : numeric vector — الأخطاء المعيارية للمعاملات
# │   ├── ci.lb                  : numeric vector — الحدود الدنيا لفترات الثقة للمعاملات
# │   ├── ci.ub                  : numeric vector — الحدود العليا لفترات الثقة للمعاملات
# │   ├── zval                   : numeric vector — إحصاءات z للمعاملات
# │   ├── pval                   : numeric vector — قيم p-value للمعاملات
# │   ├── beta                   : numeric vector — (مرادف لـ b)
# │   └── vb                     : matrix — مصفوفة التباين المشترك للمعاملات
# │
# ├── 11.2 إحصاءات النموذج (Model Statistics)
# │   │
# │   ├── QM                     : numeric — إحصاء الاختبار الشامل للمعتدلات (Omnibus Test of Moderators)
# │   ├── QMdf                   : integer vector — درجات الحرية لاختبار QM
# │   ├── QMp                    : numeric — p-value لاختبار QM الشامل
# │   │                             ► p < 0.05 = المتغير المشترك مُعدّل مهم (Effect Modifier)
# │   ├── QE                     : numeric — إحصاء Q للخطأ المتبقي (Residual Heterogeneity)
# │   ├── QEdf                   : integer vector — درجات الحرية لـ QE
# │   ├── QEp                    : numeric — p-value لـ QE
# │   ├── tau2                   : numeric — τ² المتبقي بعد تعديل المتغير المشترك
# │   ├── se.tau2                : numeric — الخطأ المعياري لـ τ²
# │   ├── I2                     : numeric — I² المتبقي
# │   ├── H2                     : numeric — H² المتبقي
# │   ├── R2                     : numeric — نسبة التباين المُفسّر بالمتغير المشترك (Pseudo-R²)
# │   │                             ► 0-100%: مقدار τ² المُخفّض بإضافة المتغير المشترك
# │   ├── k                      : integer — عدد الملاحظات (المقارنات)
# │   ├── p                      : integer — عدد المعاملات
# │   ├── m                      : integer — عدد المعاملات بما فيها القاطع
# │   ├── method                 : character — طريقة التقدير (مثل "REML")
# │   └── int.only               : logical — هل النموذج يحتوي على القاطع فقط؟
# │
# ├── 11.3 القيم المُقدّرة والبواقي (Fitted Values & Residuals)
# │   │
# │   ├── fitted                 : numeric vector — القيم المُقدّرة (Fitted Values)
# │   ├── resid                  : numeric vector — البواقي (Residuals)
# │   ├── weights                : numeric vector — الأوزان
# │   ├── X                      : matrix — مصفوفة التصميم (Design Matrix)
# │   └── yi                     : numeric vector — متجه الاستجابة (Response = TE)
# │
# ├── 11.4 بيانات إضافية (Additional Metadata)
# │   │
# │   ├── covar                  : numeric/factor vector — المتغير المشترك المُدخل
# │   ├── assumption             : character — نوع الافتراض ("common", "independent")
# │   ├── x                      : netmeta object — كائن netmeta الأصلي
# │   └── .netmetareg            : logical — علامة تمييز كائن netmetareg
# │
# └── 11.5 ► ملاحظة: netmetareg يُرجع كائن rma.uni من حزمة metafor مع عناصر إضافية
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  12. netbind() — دمج نتائج تحليلات شبكية متعددة                          █
# █      Combine Results from Multiple NMAs                                   █
# █      الاستدعاء: netbind(x1, x2, ..., name = NULL)                        █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netbind_object [List | Class: "netbind" — ~15+ عنصر]
# │
# ├── 12.1 النتائج المُجمعة (Combined Results)
# │   │
# │   ├── common                 : data.frame — النتائج المُجمعة (Common Effect) لجميع النماذج
# │   │                             ► أعمدة: name, comparison, TE, seTE, lower, upper, statistic, p
# │   ├── fixed                  : data.frame — (مرادف قديم)
# │   ├── random                 : data.frame — النتائج المُجمعة (Random Effects) لجميع النماذج
# │   ├── trts                   : list — قائمة العلاجات من كل نموذج
# │   ├── k                      : integer vector — عدد الدراسات في كل نموذج
# │   ├── n                      : integer vector — عدد العلاجات في كل نموذج
# │   └── m                      : integer vector — عدد المقارنات في كل نموذج
# │
# ├── 12.2 إعدادات الدمج (Binding Settings)
# │   │
# │   ├── name                   : character vector — أسماء النماذج المُدمجة
# │   ├── reference.group        : character — العلاج المرجعي
# │   ├── sm                     : character — المقياس الإحصائي
# │   ├── backtransf             : logical — التحويل العكسي
# │   ├── x                      : list — قائمة كائنات netmeta الأصلية
# │   └── version                : character — إصدار الحزمة
# │
# └── 12.3 ► يُستخدم مع forest.netbind() لرسم forest plots مقارنة بين عدة NMA
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  13. rankogram() — الرسم البياني لاحتمالات الترتيب                       █
# █      Rankograms & SUCRA (Salanti et al., 2011)                           █
# █      الاستدعاء: rankogram(x, nsim = 1000, ...)                           █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# rankogram_object [List | Class: "rankogram" — ~15+ عنصر]
# │
# ├── 13.1 مصفوفات الاحتمالات (Probability Matrices)
# │   │   ► مصفوفات [N × N]: الصفوف = العلاجات, الأعمدة = الرتب (Rank 1 إلى Rank N)
# │   │
# │   ├── ranking.matrix.common  : matrix [N×N] — مصفوفة احتمالات الترتيب (Common Effect)
# │   │                             ► cell[i,j] = احتمال أن يكون العلاج i في الرتبة j
# │   │                             ► مجموع كل صف = 1
# │   ├── ranking.matrix.fixed   : matrix [N×N] — (مرادف قديم)
# │   ├── ranking.matrix.random  : matrix [N×N] — مصفوفة احتمالات الترتيب (Random Effects)
# │   ├── cumrank.matrix.common  : matrix [N×N] — مصفوفة الاحتمالات التراكمية (Common)
# │   │                             ► cell[i,j] = احتمال أن يكون العلاج i في الرتبة j أو أفضل
# │   │                             ► SUCRA = المساحة تحت منحنى الترتيب التراكمي
# │   ├── cumrank.matrix.fixed   : matrix [N×N] — (مرادف قديم)
# │   └── cumrank.matrix.random  : matrix [N×N] — مصفوفة الاحتمالات التراكمية (Random)
# │
# ├── 13.2 درجات SUCRA (Surface Under Cumulative Ranking Curve)
# │   │
# │   ├── ranking.common         : named numeric vector — درجات SUCRA (Common)
# │   │                             ► 0-1: 1 = أفضل مرتبة دائماً
# │   ├── ranking.fixed          : named numeric vector — (مرادف قديم)
# │   ├── ranking.random         : named numeric vector — درجات SUCRA (Random)
# │   ├── meanrank.common        : named numeric vector — متوسط الرتبة لكل علاج (Common)
# │   ├── meanrank.fixed         : named numeric vector — (مرادف قديم)
# │   └── meanrank.random        : named numeric vector — متوسط الرتبة لكل علاج (Random)
# │
# ├── 13.3 إعدادات المحاكاة (Simulation Settings)
# │   │
# │   ├── nsim                   : integer — عدد عمليات المحاكاة (Monte Carlo draws)
# │   ├── small.values           : character — اتجاه الأفضلية ("good", "bad")
# │   ├── common                 : logical — هل النموذج المشترك مُفعّل؟
# │   ├── random                 : logical — هل النموذج العشوائي مُفعّل؟
# │   ├── sm                     : character — المقياس الإحصائي
# │   ├── trts                   : character vector — أسماء العلاجات
# │   ├── x                      : netmeta object — الكائن الأصلي
# │   └── version                : character — إصدار الحزمة
# │
# └── 13.4 ► يُستخدم مع plot.rankogram() لرسم الرانكوغرام
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  14. pairwise() — حساب المقارنات الزوجية من بيانات الأذرع                █
# █      Calculate Pairwise Comparisons from Arm-Level Data                   █
# █      الاستدعاء: pairwise(treat, event, n, data, studlab, sm = "OR", ...) █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# pairwise_output [data.frame | Class: "pairwise" — ~15+ عمود]
# │
# ├── 14.1 أعمدة البيانات الناتجة (Output Columns)
# │   │
# │   ├── studlab                : character — ملصق الدراسة
# │   ├── treat1                 : character — العلاج الأول في المقارنة
# │   ├── treat2                 : character — العلاج الثاني في المقارنة
# │   ├── TE                     : numeric — حجم الأثر المحسوب (على مقياس log إن لزم)
# │   │                             ► log(OR), log(RR), log(HR), MD, SMD حسب sm
# │   ├── seTE                   : numeric — الخطأ المعياري المحسوب
# │   ├── event1                 : integer — عدد الأحداث في ذراع العلاج 1 (بيانات ثنائية)
# │   ├── n1                     : integer — حجم العينة في ذراع العلاج 1
# │   ├── event2                 : integer — عدد الأحداث في ذراع العلاج 2 (بيانات ثنائية)
# │   ├── n2                     : integer — حجم العينة في ذراع العلاج 2
# │   ├── mean1                  : numeric — المتوسط في ذراع العلاج 1 (بيانات مستمرة)
# │   ├── sd1                    : numeric — الانحراف المعياري (ذراع 1)
# │   ├── mean2                  : numeric — المتوسط في ذراع العلاج 2 (بيانات مستمرة)
# │   ├── sd2                    : numeric — الانحراف المعياري (ذراع 2)
# │   └── (أعمدة إضافية من البيانات الأصلية يتم الاحتفاظ بها تلقائياً)
# │
# ├── 14.2 سمات إضافية (Attributes)
# │   │
# │   ├── sm                     : character — المقياس الإحصائي المُختار
# │   ├── incr                   : numeric — قيمة تصحيح الاستمرارية
# │   ├── allincr                : logical — تصحيح لكل الدراسات؟
# │   └── addincr                : logical — تصحيح إضافي؟
# │
# └── 14.3 ► ملاحظة: pairwise() تحول بيانات الأذرع إلى بيانات مقارنات زوجية جاهزة لـ netmeta()
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  15. netconnection() — فحص اتصال الشبكة                                  █
# █      Check Network Connectivity                                          █
# █      الاستدعاء: netconnection(treat1, treat2, studlab, data, ...)         █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netconnection_object [List | Class: "netconnection" — ~10+ عنصر]
# │
# ├── 15.1 نتائج الاتصال (Connectivity Results)
# │   │
# │   ├── n.subnets              : integer — عدد الشبكات الفرعية المتصلة
# │   │                             ► 1 = شبكة متصلة بالكامل ✓
# │   │                             ► >1 = شبكة منفصلة (Disconnected) ✗
# │   ├── D.matrix               : matrix [N×N] — مصفوفة المسافات بين العلاجات
# │   │                             ► D[i,j] = أقصر مسافة (عدد الأضلاع) بين العلاج i والعلاج j
# │   │                             ► Inf = غير متصلين
# │   ├── A.matrix               : matrix [N×N] — مصفوفة التجاور (0/1)
# │   │                             ► 1 = يوجد دليل مباشر بين العلاجين
# │   ├── subnet                 : named integer vector — رقم الشبكة الفرعية لكل علاج
# │   │                             ► إذا كل العلاجات لها نفس الرقم = شبكة متصلة
# │   ├── trts                   : character vector — أسماء العلاجات
# │   ├── k                      : integer — عدد الدراسات
# │   ├── n                      : integer — عدد العلاجات
# │   └── m                      : integer — عدد المقارنات
# │
# └── 15.2 بيانات وصفية
#     │
#     ├── treat1                 : character vector — العلاج الأول
#     ├── treat2                 : character vector — العلاج الثاني
#     ├── studlab                : character vector — ملصقات الدراسات
#     └── version                : character — إصدار الحزمة
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  16. netcontrib() — مصفوفة المساهمة                                      █
# █      Contribution Matrix (Papakonstantinou et al., 2018; Davies, 2022)   █
# █      الاستدعاء: netcontrib(x, method = "shortestpath", ...)              █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netcontrib_object [List | Class: "netcontrib" — ~15+ عنصر]
# │
# ├── 16.1 مصفوفة المساهمة (Contribution Matrix)
# │   │
# │   ├── common                 : matrix — مصفوفة المساهمة (Common Effect)
# │   │                             ► أبعاد: [عدد المقارنات الشبكية × عدد المقارنات المباشرة]
# │   │                             ► cell[i,j] = نسبة مساهمة الدليل المباشر j في تقدير المقارنة الشبكية i
# │   │                             ► مجموع كل صف = 1 (100%)
# │   ├── fixed                  : matrix — (مرادف قديم)
# │   ├── random                 : matrix — مصفوفة المساهمة (Random Effects)
# │   ├── nchar.trts             : integer — عدد الأحرف في أسماء العلاجات المعروضة
# │   └── hatmatrix.F1000        : matrix — مصفوفة القبعة (Hat Matrix) بطريقة F1000
# │
# ├── 16.2 إعدادات وبيانات وصفية
# │   │
# │   ├── method                 : character — طريقة الحساب
# │   │                             ► "shortestpath" = أقصر مسار (Papakonstantinou 2018)
# │   │                             ► "randomwalk" = المشي العشوائي (Davies 2022)
# │   │                             ► "least.squares" = المربعات الصغرى
# │   ├── sm                     : character — المقياس الإحصائي
# │   ├── trts                   : character vector — أسماء العلاجات
# │   ├── x                      : netmeta object — الكائن الأصلي
# │   └── version                : character — إصدار الحزمة
# │
# └── 16.3 ► يُستخدم مع print.netcontrib() لعرض المساهمات
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  17. netcomplex() — تقديرات التدخلات المعقدة                             █
# █      Complex Intervention Estimates                                       █
# █      الاستدعاء: netcomplex(x, complex = NULL, ...)                       █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netcomplex_object [List | Class: "netcomplex" — ~10+ عنصر]
# │
# ├── 17.1 تقديرات التدخلات المعقدة
# │   │
# │   ├── TE.common              : named numeric vector — أثر التدخل المعقد (Common)
# │   ├── TE.random              : named numeric vector — أثر التدخل المعقد (Random)
# │   ├── seTE.common            : named numeric vector — الخطأ المعياري (Common)
# │   ├── seTE.random            : named numeric vector — الخطأ المعياري (Random)
# │   ├── lower.common           : named numeric vector — حد أدنى CI (Common)
# │   ├── upper.common           : named numeric vector — حد أعلى CI (Common)
# │   ├── lower.random           : named numeric vector — حد أدنى CI (Random)
# │   ├── upper.random           : named numeric vector — حد أعلى CI (Random)
# │   ├── statistic.common       : named numeric vector — إحصاء z (Common)
# │   ├── statistic.random       : named numeric vector — إحصاء z (Random)
# │   ├── pval.common            : named numeric vector — p-value (Common)
# │   └── pval.random            : named numeric vector — p-value (Random)
# │
# └── 17.2 بيانات وصفية
#     │
#     ├── complex                : character vector — أسماء التدخلات المعقدة
#     ├── comps                  : character vector — أسماء المكونات
#     ├── sm                     : character — المقياس الإحصائي
#     └── version                : character — إصدار الحزمة
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  18. netdistance() — مسافات الشبكة                                       █
# █      Network Distances Between Treatments                                █
# █      الاستدعاء: netdistance(x)                                            █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netdistance_output [matrix [N×N]]
# │
# ├── 18.1 مصفوفة المسافات
# │   │
# │   └── (المصفوفة نفسها)      : matrix [N×N] — مصفوفة المسافات بين كل زوج علاجات
# │                                 ► D[i,j] = أقصر مسافة (عدد الأضلاع) بين العلاج i والعلاج j
# │                                 ► 0 = نفس العلاج
# │                                 ► 1 = مقارنة مباشرة
# │                                 ► 2+ = مقارنة غير مباشرة
# │                                 ► Inf = غير متصل
# │
# └── 18.2 ► يُرجع مصفوفة رقمية فقط (وليس list)
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  19. netimpact() — تحليل التأثير                                         █
# █      Impact Analysis of Individual Studies on NMA Estimates               █
# █      الاستدعاء: netimpact(x, verbose = FALSE)                             █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netimpact_object [List | Class: "netimpact" — ~10+ عنصر]
# │
# ├── 19.1 مصفوفات التأثير (Impact Matrices)
# │   │
# │   ├── impact.common          : matrix [K × N(N-1)/2] — تأثير حذف كل دراسة على كل تقدير (Common)
# │   │                             ► الصفوف = الدراسات, الأعمدة = المقارنات الزوجية
# │   │                             ► القيم = الفرق في التقدير بعد الحذف
# │   ├── impact.fixed           : matrix — (مرادف قديم)
# │   ├── impact.random          : matrix [K × N(N-1)/2] — تأثير حذف كل دراسة (Random)
# │   ├── impact.common.absolute : matrix — التأثير المطلق (|الفرق|) (Common)
# │   └── impact.random.absolute : matrix — التأثير المطلق (|الفرق|) (Random)
# │
# ├── 19.2 ملخص التأثير (Impact Summary)
# │   │
# │   ├── mean.impact.common     : named numeric vector — متوسط التأثير لكل دراسة (Common)
# │   ├── mean.impact.random     : named numeric vector — متوسط التأثير لكل دراسة (Random)
# │   ├── studies                : character vector — أسماء الدراسات
# │   ├── x                      : netmeta object — الكائن الأصلي
# │   └── version                : character — إصدار الحزمة
# │
# └── 19.3 ► يُستخدم لتحديد الدراسات المؤثرة (Influential Studies)
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  20. netpairwise() — التحليل التجميعي الزوجي لكل مقارنة                  █
# █      Pairwise Meta-Analysis for Each Direct Comparison                   █
# █      الاستدعاء: netpairwise(x, separate = FALSE, ...)                    █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netpairwise_object [List | Class: "netpairwise" — ~10+ عنصر]
# │
# ├── 20.1 نتائج التحليل الزوجي (Pairwise Results)
# │   │
# │   ├── common                 : data.frame — نتائج التحليل الزوجي المُجمع (Common Effect)
# │   │                             ► أعمدة: comparison, TE, seTE, lower, upper, z, p, k, Q, I2, tau2
# │   ├── fixed                  : data.frame — (مرادف قديم)
# │   ├── random                 : data.frame — نتائج التحليل الزوجي المُجمع (Random Effects)
# │   ├── k                      : named integer vector — عدد الدراسات لكل مقارنة
# │   ├── Q                      : named numeric vector — Q لعدم التجانس لكل مقارنة
# │   ├── I2                     : named numeric vector — I² لكل مقارنة
# │   └── tau2                   : named numeric vector — τ² لكل مقارنة
# │
# ├── 20.2 قائمة كائنات metagen (Individual Meta-Analyses)
# │   │
# │   ├── meta                   : list of "metagen" objects — كائن تحليل تجميعي لكل مقارنة
# │   │                             ► كل كائن metagen يحتوي على جميع مخرجات meta::metagen()
# │   ├── comparisons            : character vector — أسماء المقارنات (مثل "Drug C vs Drug A")
# │   ├── x                      : netmeta object — الكائن الأصلي
# │   └── version                : character — إصدار الحزمة
# │
# └── 20.3 ► يُستخدم مع forest.netpairwise() لرسم forest plot لكل مقارنة مباشرة
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  21. netposet() — الترتيب الجزئي للعلاجات                                █
# █      Partial Order of Treatments (Poset) & Hasse Diagram                 █
# █      (Carlsen & Bruggemann, 2014; Rücker & Schwarzer, 2017)              █
# █      الاستدعاء: netposet(x1, x2, ..., outcomes = NULL)                   █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netposet_object [List | Class: "netposet" — ~15+ عنصر]
# │
# ├── 21.1 مصفوفات الأفضلية (Dominance Matrices)
# │   │
# │   ├── M0                     : matrix [N×N] — مصفوفة الهيمنة (Dominance Matrix)
# │   │                             ► cell[i,j] = 1 إذا العلاج i أفضل من j في جميع المحصلات
# │   │                             ► cell[i,j] = 0 إذا لا يمكن المقارنة (غير قابل للمقارنة)
# │   ├── M.common               : matrix [N×N] — مصفوفة الأفضلية المعنوية (Common)
# │   │                             ► تأخذ في الاعتبار الدلالة الإحصائية
# │   ├── M.random               : matrix [N×N] — مصفوفة الأفضلية المعنوية (Random)
# │   ├── P0                     : matrix [N×N] — مصفوفة الأفضلية الخام (Raw Preference Matrix)
# │   └── O                      : matrix [N × عدد المحصلات] — مصفوفة الترتيب لكل محصلة
# │
# ├── 21.2 بيانات الترتيب الجزئي (Poset Data)
# │   │
# │   ├── trts                   : character vector — أسماء العلاجات
# │   ├── outcomes               : character vector — أسماء المحصلات (Outcomes)
# │   ├── small.values           : character vector — اتجاه الأفضلية لكل محصلة
# │   ├── common                 : logical — النموذج المشترك مُفعّل؟
# │   ├── random                 : logical — النموذج العشوائي مُفعّل؟
# │   ├── n                      : integer — عدد العلاجات
# │   ├── n.outcomes             : integer — عدد المحصلات
# │   └── version                : character — إصدار الحزمة
# │
# └── 21.3 ► يُستخدم مع plot.netposet() أو hasse() لرسم مخطط هاسه (Hasse Diagram)
#     ► hasse(x) ← يرسم مخطط هاسه للترتيب الجزئي
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  22. decomp.design() — تفكيك Q حسب التصميم                               █
# █      Design-Based Q Decomposition (Krahn et al., 2013)                   █
# █      الاستدعاء: decomp.design(x)                                          █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# decomp.design_object [List | Class: "decomp.design" — ~10+ عنصر]
# │
# ├── 22.1 جداول التفكيك (Decomposition Tables)
# │   │
# │   ├── Q.decomp               : data.frame — التفكيك الإجمالي لـ Q
# │   │                             ► أعمدة: source, df, Q, pval
# │   │                             ► source = "Total", "Within designs", "Between designs"
# │   ├── Q.het.design           : data.frame — Q لعدم التجانس داخل كل تصميم
# │   │                             ► أعمدة: design, df, Q, pval
# │   │                             ► صف لكل تصميم (مثل "Drug A:Drug C", "Drug B:Drug A")
# │   ├── Q.inc.detach           : data.frame — Q لعدم الاتساق عند فصل كل تصميم
# │   │                             ► أعمدة: design, df, Q, pval
# │   │                             ► يُظهر مساهمة كل تصميم في عدم الاتساق الإجمالي
# │   └── Q.inc.detach.random    : data.frame — نفس السابق ولكن للنموذج العشوائي
# │
# ├── 22.2 بيانات وصفية
# │   │
# │   ├── x                      : netmeta object — الكائن الأصلي
# │   ├── random                 : logical — النموذج العشوائي مُفعّل؟
# │   ├── tau2                   : numeric — τ²
# │   └── version                : character — إصدار الحزمة
# │
# └── 22.3 ► يُستخدم لتحديد مصادر عدم الاتساق في الشبكة
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  23. netmeasures() — مقاييس تدفق الأدلة                                  █
# █      Evidence Flow Measures (König et al., 2013)                         █
# █      الاستدعاء: netmeasures(x, random = x$random)                        █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# netmeasures_object [List | Class: "netmeasures" — ~10+ عنصر]
# │
# ├── 23.1 مقاييس تدفق الأدلة (Evidence Measures)
# │   │
# │   ├── proportion             : matrix [N×N] — نسبة المساهمة المباشرة (Direct Evidence Proportion)
# │   │                             ► 0-1: نسبة الدليل المباشر في تقدير كل مقارنة شبكية
# │   ├── common.direct          : matrix [N×N] — التقدير المباشر (Common)
# │   ├── common.indirect        : matrix [N×N] — التقدير غير المباشر (Common)
# │   ├── random.direct          : matrix [N×N] — التقدير المباشر (Random)
# │   ├── random.indirect        : matrix [N×N] — التقدير غير المباشر (Random)
# │   ├── meanpath               : matrix [N×N] — متوسط طول المسار لكل مقارنة
# │   │                             ► قيم أعلى = مقارنة تعتمد أكثر على أدلة غير مباشرة بعيدة
# │   ├── minpar                 : matrix [N×N] — الحد الأدنى للتوازي (Minimum Parallelism)
# │   │                             ► قيم أعلى = مقارنة مدعومة بمسارات أدلة متعددة ومتنوعة
# │   └── evidence               : data.frame — ملخص شامل لمقاييس الأدلة لكل مقارنة
# │
# ├── 23.2 بيانات وصفية
# │   │
# │   ├── x                      : netmeta object — الكائن الأصلي
# │   ├── random                 : logical — هل استُخدم النموذج العشوائي؟
# │   └── version                : character — إصدار الحزمة
# │
# └── 23.3 ► تُستخدم لتقييم قوة ومصداقية كل تقدير شبكي
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  24. funnel.netmeta() — رسم القمع المعدّل للمقارنات                      █
# █      Comparison-Adjusted Funnel Plot (Chaimani & Salanti, 2012)          █
# █      الاستدعاء: funnel(x, order = NULL, ...)                              █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# funnel_output [Invisible list — ~8+ عنصر]
# │
# ├── 24.1 بيانات رسم القمع (Funnel Plot Data)
# │   │
# │   ├── TE.adj                 : numeric vector — الأثر المُعدّل (Comparison-Adjusted TE)
# │   │                             ► = TE_observed - TE_NMA (الانحراف عن تقدير الشبكة)
# │   ├── seTE                   : numeric vector — الخطأ المعياري لكل مقارنة
# │   ├── comparison             : character vector — تسميات المقارنات
# │   ├── studlab                : character vector — ملصقات الدراسات
# │   ├── order                  : character vector — ترتيب العلاجات المستخدم
# │   ├── linreg                 : lm object — نتائج اختبار الانحراف (Egger's test)
# │   │                             ► p-value < 0.05 = دليل على تحيز النشر
# │   └── x                      : netmeta object — الكائن الأصلي
# │
# └── 24.2 ► الإخراج الرئيسي: رسم بياني قمعي مع خط التماثل
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  25. forest.netmeta() — رسم الغابة الشبكي                                █
# █      Forest Plot for Network Meta-Analysis Results                       █
# █      الاستدعاء: forest(x, reference.group = x$reference.group, ...)       █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# forest_output [رسم بياني — لا يُرجع كائن]
# │
# ├── 25.1 ► الإخراج الرئيسي هو رسم بياني (Forest Plot)
# │   │   ► يعرض HR/OR [CI] لكل علاج مقابل المرجع
# │   │   ► يدعم common, random, أو كليهما
# │   │   ► يدعم التحويل العكسي (backtransf)
# │   │   ► يدعم الترتيب حسب P-score, TE, أو أبجدي
# │   │
# │   ├── ► المعاملات الرئيسية:
# │   │   ├── reference.group    : العلاج المرجعي
# │   │   ├── sortvar            : متغير الترتيب (Pscore, TE, ...)
# │   │   ├── smlab              : تسمية المقياس ("Hazard Ratio", "Odds Ratio")
# │   │   ├── drop.reference.group : حذف المرجع من الرسم
# │   │   ├── label.left         : تسمية يسار خط التماثل
# │   │   └── label.right        : تسمية يمين خط التماثل
# │   │
# │   └── ► لا يُرجع قيم — الإخراج بصري فقط
# │
# └── 25.2 ► متغيرات Forest الإضافية:
#     ├── forest.netbind()       : forest plot لمقارنة عدة NMA
#     ├── forest.netsplit()      : forest plot للأدلة المباشرة vs غير المباشرة
#     ├── forest.netcomb()       : forest plot للمكونات
#     ├── forest.netpairwise()   : forest plot لكل مقارنة زوجية مباشرة
#     └── forest.netcomplex()    : forest plot للتدخلات المعقدة
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  26. subgroup.netmeta() — التحليل الشبكي حسب المجموعات الفرعية           █
# █      Subgroup Network Meta-Analysis                                      █
# █      الاستدعاء: subgroup.netmeta(x, subgroup, ...)                        █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# subgroup.netmeta_object [List | Class: "subgroup.netmeta" — ~20+ عنصر]
# │
# ├── 26.1 نتائج المجموعات الفرعية (Subgroup Results)
# │   │
# │   ├── k.all                  : integer — إجمالي عدد الدراسات (كل المجموعات)
# │   ├── k.w                    : named integer vector — عدد الدراسات في كل مجموعة فرعية
# │   ├── TE.common.w            : list of matrices — تقديرات الأثر لكل مجموعة (Common)
# │   ├── TE.random.w            : list of matrices — تقديرات الأثر لكل مجموعة (Random)
# │   ├── seTE.common.w          : list of matrices — الأخطاء المعيارية لكل مجموعة (Common)
# │   ├── seTE.random.w          : list of matrices — الأخطاء المعيارية لكل مجموعة (Random)
# │   ├── lower.common.w         : list of matrices — حدود CI الدنيا (Common)
# │   ├── upper.common.w         : list of matrices — حدود CI العليا (Common)
# │   ├── lower.random.w         : list of matrices — حدود CI الدنيا (Random)
# │   ├── upper.random.w         : list of matrices — حدود CI العليا (Random)
# │   ├── pval.common.w          : list of matrices — p-values (Common)
# │   ├── pval.random.w          : list of matrices — p-values (Random)
# │   ├── tau2.w                 : named numeric vector — τ² لكل مجموعة فرعية
# │   ├── I2.w                   : named numeric vector — I² لكل مجموعة فرعية
# │   └── Q.w                    : named numeric vector — Q لكل مجموعة فرعية
# │
# ├── 26.2 اختبار التفاعل بين المجموعات (Interaction Test)
# │   │
# │   ├── Q.b.common             : numeric — Q لاختبار الفرق بين المجموعات (Common)
# │   ├── df.Q.b.common          : integer — درجات الحرية
# │   ├── pval.Q.b.common        : numeric — p-value (p < 0.05 = فرق معنوي بين المجموعات)
# │   ├── Q.b.random             : numeric — Q لاختبار الفرق بين المجموعات (Random)
# │   ├── df.Q.b.random          : integer — درجات الحرية
# │   └── pval.Q.b.random        : numeric — p-value
# │
# ├── 26.3 كائنات netmeta الفرعية (Subgroup NMA Objects)
# │   │
# │   ├── net.w                  : list of netmeta objects — كائن NMA لكل مجموعة فرعية
# │   │                             ► يمكن استخدام كل كائن بشكل مستقل
# │   ├── subgroup                : factor — المتغير الفرعي
# │   ├── subgroup.levels        : character vector — مستويات المجموعات الفرعية
# │   └── n.subgroups            : integer — عدد المجموعات الفرعية
# │
# └── 26.4 بيانات وصفية
#     │
#     ├── x                      : netmeta object — الكائن الأصلي الكلي
#     ├── sm                     : character — المقياس الإحصائي
#     ├── reference.group        : character — العلاج المرجعي
#     └── version                : character — إصدار الحزمة
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  27. nettable() — جدول نتائج مُنسّق                                     █
# █      Formatted Results Table                                              █
# █      الاستدعاء: nettable(x, ...)                                          █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# nettable_output [List | Class: "nettable"]
# │
# ├── 27.1 جداول مُنسّقة (Formatted Tables)
# │   │
# │   ├── common                 : character matrix — جدول نتائج منسق (Common)
# │   ├── fixed                  : character matrix — (مرادف قديم)
# │   ├── random                 : character matrix — جدول نتائج منسق (Random)
# │   ├── direct                 : character matrix — جدول الأدلة المباشرة
# │   ├── indirect               : character matrix — جدول الأدلة غير المباشرة
# │   └── predict                : character matrix — جدول فترات التنبؤ
# │
# └── 27.2 إعدادات
#     │
#     ├── backtransf             : logical — التحويل العكسي
#     ├── digits                 : integer — الأرقام العشرية
#     ├── bracket                : character — نوع الأقواس
#     └── separator              : character — الفاصل
#
#
# ═══════════════════════════════════════════════════════════════════════════════
# ═══════════════════════════════════════════════════════════════════════════════
#
#  دوال مساعدة إضافية (Auxiliary / Utility Functions)
#
# ═══════════════════════════════════════════════════════════════════════════════
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  A1. summary.netmeta() — ملخص شامل                                      █
# █      الاستدعاء: summary(netmeta_object)                                   █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# summary_netmeta [List | Class: "summary.netmeta"]
# │
# ├── ► يحتوي على جميع عناصر netmeta() بالإضافة إلى:
# │
# ├── comparison                : data.frame — ملخص جدولي لجميع المقارنات مع المرجع
# │                               ► أعمدة: TE.common, seTE.common, lower.common, upper.common,
# │                               ►        TE.random, seTE.random, lower.random, upper.random,
# │                               ►        statistic.common, pval.common, statistic.random, pval.random
# ├── comparison.nma.common     : data.frame — تقديرات NMA التفصيلية (Common)
# ├── comparison.nma.random     : data.frame — تقديرات NMA التفصيلية (Random)
# ├── studies                   : character vector — قائمة الدراسات
# ├── narms                     : integer vector — عدد الأذرع لكل دراسة
# └── text.*                    : character — نصوص العرض المختلفة
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  A2. print.netmeta() — طباعة النتائج                                     █
# █      الاستدعاء: print(netmeta_object)                                     █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# ► يطبع:
# │
# ├── Original data (comparisons)     : جدول المقارنات الأصلية
# ├── Number of studies                : عدد الدراسات
# ├── Number of pairwise comparisons   : عدد المقارنات
# ├── Number of treatments             : عدد العلاجات
# ├── Number of designs                : عدد التصاميم
# ├── Results (common / random effect) : النتائج مقابل المرجع
# │   ► لكل علاج: TE [CI], z, p
# ├── Quantifying heterogeneity        : τ², τ, I²
# ├── Tests of heterogeneity           : Q_total, Q_het, Q_inc مع df و p
# └── ► لا يُرجع قيماً (يطبع فقط)
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  A3. دوال الاستخراج (Extraction / Accessor Functions)                    █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# ├── coef.netmeta(x)           : numeric vector — معاملات النموذج (= TE.ref.random)
# ├── residuals.netmeta(x)      : numeric vector — البواقي
# ├── fitted.netmeta(x)         : numeric vector — القيم المُقدّرة
# ├── weights.netmeta(x)        : numeric vector — الأوزان
# ├── vcov.netmeta(x)           : matrix — مصفوفة التباين المشترك
# ├── logLik.netmeta(x)         : numeric — دالة الأرجحية اللوغاريتمية
# ├── AIC.netmeta(x)            : numeric — معيار آكايكي للمعلومات (AIC)
# ├── BIC.netmeta(x)            : numeric — معيار بايز للمعلومات (BIC)
# └── deviance.netmeta(x)       : numeric — الانحراف (Deviance)
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  A4. nettable.netmeta() — جدول نتائج مُخصص                              █
# █      الاستدعاء: nettable(x, ...)                                          █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# ► مثل netleague() ولكن بتنسيق أبسط
#
#
# ███████████████████████████████████████████████████████████████████████████████
# █                                                                           █
# █  A5. مجموعات البيانات المُدمجة (Built-in Datasets)                       █
# █                                                                           █
# ███████████████████████████████████████████████████████████████████████████████
#
# ├── Dong2013            : data.frame — بيانات Dong et al. (2013) — تخثر وريدي
# ├── Gupta2013           : data.frame — بيانات Gupta et al. (2013) — مضادات الاكتئاب
# ├── Linde2015           : data.frame — بيانات Linde et al. (2015) — علاج الاكتئاب (18 علاج)
# ├── Linde2016           : data.frame — بيانات Linde et al. (2016) — اكتئاب حاد
# ├── Senn2013            : data.frame — بيانات Senn et al. (2013) — مرض السكري (HbA1c)
# ├── smokingcessation    : data.frame — بيانات الإقلاع عن التدخين (4 علاجات)
# ├── Stowe2010           : data.frame — بيانات Stowe et al. (2010) — مرض باركنسون
# ├── Woods2010           : data.frame — بيانات Woods et al. (2010) — لقاح الإنفلونزا
# ├── Franchini2012       : data.frame — بيانات Franchini et al. (2012) — مثال CNMA
# ├── Baker2009           : data.frame — بيانات Baker et al. (2009) — تسمم حملي
# └── dietaryfat          : data.frame — بيانات تقليل الدهون الغذائية
#
#
# ═══════════════════════════════════════════════════════════════════════════════
# ═══════════════════════════════════════════════════════════════════════════════
#
#  ملاحظات ختامية مهمة (CRITICAL NOTES)
#
# ═══════════════════════════════════════════════════════════════════════════════
#
# [ملاحظة 1] التوافقية العكسية (Backward Compatibility):
# ► العناصر المسماة *.fixed هي مرادفات قديمة (deprecated) لـ *.common
# ► في الإصدارات الحديثة (≥ 2.5-0) يُفضل استخدام .common بدلاً من .fixed
# ► الوظيفة متطابقة تماماً: TE.fixed ≡ TE.common
#
# [ملاحظة 2] مقياس القيم (Scale):
# ► جميع التقديرات على المقياس الخام (log-scale لـ HR, OR, RR)
# ► للتحويل إلى المقياس الطبيعي: exp(TE), exp(lower), exp(upper)
# ► للحصول على HR من log-HR: HR = exp(TE)
#
# [ملاحظة 3] اتجاه المقارنة (Direction):
# ► TE[i,j] = أثر العلاج i مقارنة بالعلاج j
# ► TE[i,j] = -TE[j,i] (مصفوفة متماثلة عكسية)
# ► TE[i,i] = 0 (القطر دائماً صفر)
#
# [ملاحظة 4] تفسير P-scores:
# ► P-score = 1: العلاج أفضل من جميع العلاجات الأخرى
# ► P-score = 0: العلاج أسوأ من جميع العلاجات الأخرى
# ► P-score = 0.5: العلاج متوسط الأداء
# ► P-scores مكافئة وظيفياً لـ SUCRA بدون محاكاة
#
# [ملاحظة 5] اختبارات الاتساق (Consistency Tests):
# ► Q.inconsistency > 0 مع p < 0.05 = عدم اتساق (Direct ≠ Indirect)
# ► netsplit() يُظهر مصدر عدم الاتساق لكل مقارنة
# ► decomp.design() يُظهر مساهمة كل تصميم
# ► netheat() يُعرض بصرياً
#
# [ملاحظة 6] أهم دوال الرسم (Key Plotting Functions):
# ► netgraph()          : رسم الشبكة
# ► forest()            : رسم الغابة (Forest Plot)
# ► funnel()            : رسم القمع (Funnel Plot)
# ► netheat()           : مخطط الحرارة الشبكي
# ► heatplot()          : مخطط حراري مُحسّن
# ► plot.rankogram()    : رانكوغرام
# ► plot.netposet()     : مخطط هاسه (Hasse Diagram)
# ► plot.netrank()      : رسم P-scores
#
# ═══════════════════════════════════════════════════════════════════════════════
# نهاية الملف المرجعي الشامل
# Complete Reference File — End
# ═══════════════════════════════════════════════════════════════════════════════
