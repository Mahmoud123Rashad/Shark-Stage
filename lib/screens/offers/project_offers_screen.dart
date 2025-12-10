import 'package:flutter/material.dart';
// 💡 تأكد من أن هذا المسار صحيح في مشروعك
import 'package:finial_project/screens/offers/project_offers_service.dart'; 

class ProjectOffersScreen extends StatefulWidget {
  final String projectId;
  // 🟢 تم إضافة initialOfferId لقبول القيمة الممررة من الإشعار
  final String? initialOfferId; 

  // 💡 يجب أن يكون initialOfferId اختيارياً في البناء
  const ProjectOffersScreen({
    super.key, 
    required this.projectId, 
    this.initialOfferId, 
  });

  @override
  State<ProjectOffersScreen> createState() => _ProjectOffersScreenState();
}

class _ProjectOffersScreenState extends State<ProjectOffersScreen> {
  bool _isLoading = true;
  List<dynamic> _offers = [];

  // 💡 يمكنك إضافة متحكم هنا إذا كنت تستخدم قائمة (ListView) وتريد التمرير إليها
  // final ScrollController _scrollController = ScrollController(); 

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }
  
  // 💡 لا تنسَ إضافة dispose للمتحكم إذا أضفته:
  /*
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  */

  Future<void> _loadOffers() async {
    // 1. جلب العروض
    final data = await ProjectOffersService.fetchOffers(widget.projectId);
    
    // 2. تحديث الحالة
    if (!mounted) return;
    setState(() {
      _offers = data;
      _isLoading = false;
    });

    // 🛑 المنطق الجديد لتحديد العرض بعد تحميل القائمة
    if (widget.initialOfferId != null && _offers.isNotEmpty) {
      // البحث عن العرض الذي يتطابق مع المعرّف
      final targetOfferIndex = _offers.indexWhere((offer) => offer['_id'] == widget.initialOfferId);
      
      if (targetOfferIndex != -1) {
        // 3. إذا تم العثور عليه، يمكنك هنا إضافة منطق التمرير (Scroll) أو تمييزه
        print('✅ Offer ID found: ${widget.initialOfferId} at index $targetOfferIndex. Should focus on it now.');
        
        // ** مثال على تطبيق التمرير (يتطلب ScrollController) **
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   _scrollController.animateTo(...); // أضف منطق التمرير هنا
        // });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "cancelled":
        return Colors.grey;
      default:
        return Colors.amber;
    }
  }

  // دالة مساعدة لإنشاء بطاقة العرض (Offer Card)
  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final theme = Theme.of(context);
    final status = offer['status'] as String;
    final statusText = status.toUpperCase();
    final statusColor = _statusColor(status);
    
    // 💡 إضافة خاصية لتمييز العرض المستهدف إذا تطابق الـ ID
    final isTargetOffer = offer['_id'] == widget.initialOfferId;

    return Card(
      // 💡 تغيير لون الإطار للتمييز
      color: isTargetOffer ? statusColor.withOpacity(0.1) : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // 💡 إضافة إطار ملون للعرض المستهدف
        side: isTargetOffer ? BorderSide(color: statusColor, width: 2) : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Offer ID: ${offer['_id'].toString().substring(0, 8)}...',
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Offered by: ${offer['offeredBy']['firstName'] ?? 'N/A'}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            Text(
              'Amount: \$${offer['amount']?.toStringAsFixed(2) ?? 'N/A'}',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Percentage: ${offer['percentage']?.toStringAsFixed(2) ?? 'N/A'}%',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 15),
            // هنا يمكنك إضافة أزرار القبول/الرفض
            if (status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _rejectOffer(offer['_id']),
                    child: Text('Reject', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _acceptOffer(offer['_id']),
                    child: const Text('Accept'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptOffer(String offerId) async {
    // ... (منطق القبول)
    if (offerId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Offer'),
        content: const Text('Are you sure you want to accept this offer? This will close the project for further investment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final success = await ProjectOffersService.acceptOffer(offerId);
    
    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer accepted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOffers(); // Reload offers
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept offer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectOffer(String offerId) async {
    // ... (منطق الرفض)
    if (offerId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Offer'),
        content: const Text('Are you sure you want to reject this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final success = await ProjectOffersService.rejectOffer(offerId);
    
    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer rejected successfully'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadOffers(); // Reload offers
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject offer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Offers"),
        backgroundColor:Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offers.isEmpty
              ? Center(
                  child: Text(
                    'No offers found for this project.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  // controller: _scrollController, // 💡 إذا أضفت المتحكم
                  itemCount: _offers.length,
                  itemBuilder: (context, index) {
                    return _buildOfferCard(_offers[index]);
                  },
                ),
    );
  }
}