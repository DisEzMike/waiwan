import 'elderlypersonclass.dart';
import 'reviewclass.dart';
import 'chatclass.dart';

// Demo chat messages - will be replaced with WebSocket data later
final List<ChatMessage> demoChatMessages = [
  ChatMessage(
    message: "สวัสดีครับ/ค่ะ",
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    senderName: "ฉัน",
  ),
  ChatMessage(
    message: "เรื่องการรับจ้างงาน พับกระดาษ\nราคา 400 บาท คุณสนใจไหม",
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    senderName: "ฉัน",
  ),
  ChatMessage(
    message: "ต้องทำอะไรบ้างเหรอค่ะ",
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    senderName: "คุณ",
  ),
  ChatMessage(
    message: "ครับ พับกล่องจำนวน 100 ชุด\nเป็นกล่องสำหรับส่งโปรษณีย์",
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    senderName: "ฉัน",
  ),
  ChatMessage(
    message: "โอเคครับ\nแต่ขอเพิ่มราคาได้ไหมครับ\nเป็น 500 บาท",
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    senderName: "คุณ",
  ),
  ChatMessage(
    message: "ได้ครับ",
    isMe: true,
    timestamp: DateTime.now(),
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
    name: 'นายบาบี้ที่หนึ่งเท่านั้น',
    distance: '500 m.',
    ability: 'พับกล่อง ทำอาหาร ถักไหมพรม อาจารย์สอนวิศวกรรมโยธา ',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'ไม่มี',
    workExperience: 'อาจาร์ยวิศวกรรมศาสตร์โยธา',
    reviews: somchaiReviews,
    isVerified: true,
  ),
  ElderlyPerson(
    name: 'นายกาย',
    distance: '1 km.',
    ability: 'พับกล่อง พูดภาษาอังกฤษ ภาษาญี่ปุ่น',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'ความดัน',
    workExperience: 'ผู้รักษาความปลอดภัย',
    reviews: phasReviews,
  ),
  ElderlyPerson(
    name: 'นายไมค์',
    distance: '500 m.',
    ability: 'พับกล่อง ซ่อมเครื่องซักผ้า',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'โรคไต',
    workExperience: 'ซ่อมเครื่องใช้ไฟฟ้า',
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
    name: 'นางสดใส',
    distance: '450 m.',
    ability: 'พับกล่อง สอนการบ้านคณิตศาสตร์ ทำอาหาร',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'โรคหอบหืด',
    workExperience: 'ครูประถม',
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
    name: 'นายหมายใจ',
    distance: '700 m.',
    ability: 'พับกล่อง ทำความสะอาดบ้าน ทำอาหาร ถักไหมพรม',
    imageUrl: 'assets/images/guy_old.png',
    phoneNumber: 1234567890,
    chronicDiseases: 'ไม่มี',
    workExperience: 'แม่บ้าน',
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
