import 'elderlypersonclass.dart';
import 'reviewclass.dart';
import 'chatclass.dart';

// Demo chat messages - will be replaced with WebSocket data later
final List<ChatMessage> demoChatMessages = [
  ChatMessage(
    message: "สวัสดีครับ ผมสนใจงานที่คุณโพสต์ไว้",
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    senderName: "คุณ",
  ),
  ChatMessage(
    message: "สวัสดีค่ะ งานอะไรคะ?",
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
    senderName: "ฉัน",
  ),
  ChatMessage(
    message: "งานพูดกล่องค่ะ ต้องการคนช่วยพูดในงานประชุม",
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    senderName: "คุณ",
  ),
  ChatMessage(
    message: "เข้าใจแล้วค่ะ ผมมีประสบการณ์เรื่องนี้ ตอนไหนสะดวกคุยรายละเอียดคะ?",
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    senderName: "ฉัน",
  ),
];

// Sample reviews data
final List<Review> somchaiReviews = [
  Review(
    reviewId: 'r1',
    reviewerName: 'นางสาวสมหญิง ใจดี',
    rating: 5,
    comment: 'ดูแลคุณยายได้ดีมาก ใจเย็น อดทน และมีความรู้ในการดูแลผู้สูงอายุ',
    reviewDate: DateTime.now().subtract(const Duration(days: 14)),
  ),
  Review(
    reviewId: 'r2',
    reviewerName: 'คุณสมชาย มาดี',
    rating: 5,
    comment: 'มีประสบการณ์ดี ทำงานละเอียด ดูแลคุณปู่ได้อย่างดี',
    reviewDate: DateTime.now().subtract(const Duration(days: 30)),
  ),
  Review(
    reviewId: 'r3',
    reviewerName: 'นางสมศรี ใจบุญ',
    rating: 4,
    comment: 'ทำงานดี แต่บางครั้งมาสายนิดหน่อย แต่โดยรวมพอใจ',
    reviewDate: DateTime.now().subtract(const Duration(days: 60)),
  ),
];

final List<Review> phasReviews = [
  Review(
    reviewId: 'r4',
    reviewerName: 'คุณนิด สุขใส',
    rating: 5,
    comment: 'เก่งมาก ดูแลดี มาตรงเวลา',
    reviewDate: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Review(
    reviewId: 'r5',
    reviewerName: 'นายวิทย์ ดีใจ',
    rating: 4,
    comment: 'ใจดี ทำงานดี แนะนำให้เพื่อนๆ',
    reviewDate: DateTime.now().subtract(const Duration(days: 21)),
  ),
];

final List<ElderlyPerson> demoElderlyPersons = [
  ElderlyPerson(
    name: 'นายสมชาย',
    distance: '500 m.',
    ability: 'พูดกล่อง',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'เบาหวาน',
    workExperience: '10 ปี',
    reviews: somchaiReviews,
    isVerified: true,
  ),
  ElderlyPerson(
    name: 'นายภาส',
    distance: '600 m.',
    ability: 'พูดกล่อง',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'ความดัน',
    workExperience: '5 ปี',
    reviews: phasReviews,
  ),
  ElderlyPerson(
    name: 'นายคันนายน์',
    distance: '500 m.',
    ability: 'พูดกล่อง',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'โรคหัวใจ',
    workExperience: '8 ปี',
    reviews: [
      Review(
        reviewId: 'r6',
        reviewerName: 'คุณแม่มาลี',
        rating: 4,
        comment: 'ดูแลดี เอาใจใส่',
        reviewDate: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ],
  ),
  ElderlyPerson(
    name: 'นางน้อน',
    distance: '450 m.',
    ability: 'พูดกล่อง',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'โรคหอบหืด',
    workExperience: '3 ปี',
    isVerified: true,
    reviews: [
      Review(
        reviewId: 'r7',
        reviewerName: 'ป้าสุดา',
        rating: 5,
        comment: 'ดีมาก แนะนำเลย ดูแลแม่ได้ดีมาก',
        reviewDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Review(
        reviewId: 'r8',
        reviewerName: 'คุณจริง ใจดี',
        rating: 5,
        comment: 'เยี่ยมมาก มีความรู้ดี',
        reviewDate: DateTime.now().subtract(const Duration(days: 35)),
      ),
    ],
  ),
  ElderlyPerson(
    name: 'นายสมปอง',
    distance: '700 m.',
    ability: 'พูดกล่อง',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'ไม่มี',
    workExperience: '1 ปี',
    reviews: [
      Review(
        reviewId: 'r9',
        reviewerName: 'นางสาวใจดี',
        rating: 4,
        comment: 'ทำงานดี มีความรับผิดชอบ',
        reviewDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ],
  ),
];
