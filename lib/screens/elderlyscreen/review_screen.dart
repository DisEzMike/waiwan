import 'package:flutter/material.dart';
import 'package:waiwan/utils/colors.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  int _selectedAmount = 10;
  String _paymentMethod = 'QR Code';
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _openTipSheet() {
    // Local variables declared here persist across StatefulBuilder rebuilds
    int localAmount = _selectedAmount;
    String localPayment = _paymentMethod;
    final TextEditingController localCustomController = TextEditingController(
      text: _customAmountController.text,
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void applyAndClose() {
              setState(() {
                _selectedAmount = localAmount;
                _paymentMethod = localPayment;
                _customAmountController.text = localCustomController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'ส่งเงินให้ ฿$_selectedAmount ผ่าน $_paymentMethod',
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ให้ทิปผู้สูงอายุ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('กรุณาเลือกจำนวนเงินที่ต้องการให้'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children:
                        [10, 20, 30, 40].map((amount) {
                          final selected = localAmount == amount;
                          return ChoiceChip(
                            label: Text('฿$amount'),
                            selected: selected,
                            onSelected:
                                (_) =>
                                    setSheetState(() => localAmount = amount),
                            selectedColor: myPrimaryColor,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('ระบุจำนวนเงินที่ต้องการให้เอง'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: localCustomController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'ระบุจำนวน (บาท)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) {
                      final parsed = int.tryParse(v) ?? 0;
                      if (parsed > 0) setSheetState(() => localAmount = parsed);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('ช่องทางการชำระ:'),
                  RadioListTile<String>(
                    title: const Text('QR Code'),
                    value: 'QR Code',
                    groupValue: localPayment,
                    onChanged:
                        (v) =>
                            setSheetState(() => localPayment = v ?? 'QR Code'),
                  ),
                  RadioListTile<String>(
                    title: const Text('Mobile banking'),
                    value: 'Mobile banking',
                    groupValue: localPayment,
                    onChanged:
                        (v) => setSheetState(
                          () => localPayment = v ?? 'Mobile banking',
                        ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: myPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: applyAndClose,
                      child: const Text('ยืนยัน'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Dispose the temporary controller when the sheet is dismissed by any means
      try {
        localCustomController.dispose();
      } catch (_) {}
    });
  }

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.orangeAccent,
      ),
      onPressed: () => setState(() => _rating = index),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('>>> building ReviewScreen <<<');
    return Scaffold(
      backgroundColor: myBackgroundColor,
      appBar: AppBar(
        backgroundColor: myPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('รีวิว'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Container(
              //   decoration: BoxDecoration(
              //     color: mySecondaryColor,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   padding: const EdgeInsets.all(12),
              //   child: Row(
              //     children: [
              //       CircleAvatar(
              //         radius: 28,
              //         backgroundImage: AssetImage('assets/images/guy_old.png'),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: const [
              //             Text(
              //               'นายบาบี้ ที่หนึ่งเท่านั้น',
              //               style: TextStyle(fontWeight: FontWeight.bold),
              //             ),
              //             SizedBox(height: 4),
              //             Text('4.8 ⭐ (12 รีวิว)'),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'โปรดให้คะแนนการบริการ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => _buildStar(i + 1)),
              ),
              const SizedBox(height: 18),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: AssetImage(
                              'assets/images/guy.png',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'นายกาย',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'เผยแพร่เป็นสาธารณะ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: myPrimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _openTipSheet,
                            child: const Text('กดที่นี่เพื่อให้ทิป'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _commentController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'เขียนรีวิวของคุณที่นี่...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: myPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ขอบคุณสำหรับรีวิวของคุณ'),
                                backgroundColor: Color(0xFF6EB715),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Navigate back to chat screen
                            // Pop twice: first to go back to map page, then to chat
                            Navigator.of(context).pop(); // Back to map page
                            Navigator.of(context).pop(); // Back to chat screen
                          },
                          child: const Text('ส่งรีวิว'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
