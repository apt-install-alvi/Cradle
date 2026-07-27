import '../models/education.dart';

class EducationRepository {
  static List<Article> getArticles() {
    return [
      Article(
        id: '1',
        title: {
          'en': 'First Trimester: What to Expect',
          'bn': 'প্রথম ত্রৈমাসিক: কী আশা করবেন'
        },
        description: {
          'en': 'A guide to the first 12 weeks of your pregnancy journey.',
          'bn': 'আপনার গর্ভাবস্থার প্রথম ১২ সপ্তাহের একটি গাইড।'
        },
        content: {
          'en': 'The first trimester is a time of incredible change. Your body is working hard to grow a new life. You might experience fatigue, morning sickness, and emotional changes. Major organs of the baby begin to form during this period.',
          'bn': 'প্রথম ত্রৈমাসিক অবিশ্বাস্য পরিবর্তনের সময়। আপনার শরীর একটি নতুন জীবন বৃদ্ধির জন্য কঠোর পরিশ্রম করছে। আপনি ক্লান্তি, সকালের অসুস্থতা এবং আবেগীয় পরিবর্তন অনুভব করতে পারেন। এই সময়ে শিশুর প্রধান অঙ্গগুলো তৈরি হতে শুরু করে।'
        },
        category: 'Trimester',
        imageUrl: 'assets/images/pf11.jpg',
        readingTimeMinutes: 5,
        lastUpdated: '2026-07-28',
        tips: [
          'Take your prenatal vitamins daily.',
          'Stay hydrated with at least 8-10 glasses of water.',
          'Rest whenever you feel tired.',
          'Avoid raw fish and unpasteurized dairy.'
        ],
        warningSigns: [
          'Severe abdominal pain or cramping.',
          'Heavy vaginal bleeding.',
          'Persistent vomiting and inability to keep fluids down.',
          'Fever over 101°F.'
        ],
        contactDoctor: 'Contact your doctor immediately if you experience heavy bleeding, sharp abdominal pain, or extreme dizziness.',
        references: ['WHO Maternal Health Guidelines', 'Mayo Clinic Pregnancy Guide'],
      ),
      Article(
        id: '2',
        title: {
          'en': 'Nutrition During Pregnancy',
          'bn': 'গর্ভাবস্থায় পুষ্টি'
        },
        description: {
          'en': 'Essential vitamins and minerals for you and your baby.',
          'bn': 'আপনার এবং আপনার শিশুর জন্য প্রয়োজনীয় ভিটামিন এবং খনিজ।'
        },
        content: {
          'en': 'Eating a balanced diet is one of the best things you can do for your baby. Focus on leafy greens, lean protein, and whole grains. Folate, Iron, and Calcium are particularly important now.',
          'bn': 'সুষম খাবার খাওয়া আপনার শিশুর জন্য সেরা কাজগুলোর একটি। শাকসবজি, চর্বিহীন প্রোটিন এবং আস্ত শস্যের দিকে নজর দিন। ফোলেট, আয়রন এবং ক্যালসিয়াম এখন বিশেষভাবে গুরুত্বপূর্ণ।'
        },
        category: 'Nutrition',
        imageUrl: 'assets/images/pf2.jpg',
        readingTimeMinutes: 4,
        lastUpdated: '2026-07-25',
        tips: [
          'Include iron-rich foods like spinach and lean meat.',
          'Cook eggs and meat thoroughly.',
          'Wash all fruits and vegetables carefully.'
        ],
      ),
      Article(
        id: '3',
        title: {
          'en': 'Morning Sickness Relief',
          'bn': 'সকালের অসুস্থতা থেকে মুক্তি'
        },
        description: {
          'en': 'Tips and tricks to manage nausea and vomiting.',
          'bn': 'বমি বমি ভাব এবং বমি পরিচালনা করার টিপস এবং কৌশল।'
        },
        content: {
          'en': 'Morning sickness is common but can be very difficult. It often happens in the morning but can strike at any time. Try eating small, frequent meals and avoid triggers like strong smells.',
          'bn': 'সকালের অসুস্থতা সাধারণ কিন্তু খুব কঠিন হতে পারে। এটি প্রায়শই সকালে ঘটে তবে যে কোনও সময় হতে পারে। অল্প অল্প করে বারবার খাওয়ার চেষ্টা করুন এবং কড়া গন্ধের মতো ট্রিগারগুলো এড়িয়ে চলুন।'
        },
        category: 'Maternal',
        imageUrl: 'assets/images/pf8.jpg',
        readingTimeMinutes: 3,
        lastUpdated: '2026-07-20',
        tips: [
          'Keep crackers by your bedside.',
          'Try ginger tea or lemon water.',
          'Avoid greasy or spicy foods.'
        ],
      ),
      Article(
        id: '4',
        title: {
          'en': 'Safe Exercise During Pregnancy',
          'bn': 'গর্ভাবস্থায় নিরাপদ ব্যায়াম'
        },
        description: {
          'en': 'Maintain your fitness levels safely while expecting.',
          'bn': 'গর্ভবতী অবস্থায় আপনার ফিটনেস লেভেল নিরাপদে বজায় রাখুন।'
        },
        content: {
          'en': 'Exercise can help reduce backaches, constipation, and bloating. Walking, swimming, and prenatal yoga are excellent choices. Always listen to your body and dont overexert.',
          'bn': 'ব্যায়াম পিঠের ব্যথা, কোষ্ঠকাঠিন্য এবং পেট ফাঁপা কমাতে সাহায্য করতে পারে। হাঁটা, সাঁতার কাটা এবং প্রসবপূর্ব যোগব্যায়াম চমৎকার বিকল্প। সর্বদা আপনার শরীরের কথা শুনুন এবং অতিরিক্ত পরিশ্রম করবেন না।'
        },
        category: 'Exercise',
        imageUrl: 'assets/images/pf3.jpg',
        readingTimeMinutes: 6,
        lastUpdated: '2026-07-15',
        tips: [
          'Stay hydrated while exercising.',
          'Wear supportive footwear.',
          'Avoid contact sports or high-impact activities.'
        ],
      ),
      Article(
        id: '5',
        title: {
          'en': 'Preparing for Delivery',
          'bn': 'প্রসবের জন্য প্রস্তুতি'
        },
        description: {
          'en': 'What to pack and how to prepare for your big day.',
          'bn': 'আপনার বড় দিনের জন্য কী প্যাক করবেন এবং কীভাবে প্রস্তুতি নেবেন।'
        },
        content: {
          'en': 'As your due date approaches, preparing a hospital bag and having a birth plan can help you feel more in control. Know the signs of true labor versus Braxton Hicks contractions.',
          'bn': 'আপনার প্রসবের তারিখ ঘনিয়ে আসার সাথে সাথে একটি হাসপাতালের ব্যাগ প্রস্তুত করা এবং বার্থ প্ল্যান থাকা আপনাকে আরও নিয়ন্ত্রিত বোধ করতে সাহায্য করতে পারে। আসল প্রসব বেদনা এবং ব্র্যাক্সটন হিকস সংকোচনের লক্ষণগুলো জানুন।'
        },
        category: 'Baby',
        imageUrl: 'assets/images/pf6.jpg',
        readingTimeMinutes: 7,
        lastUpdated: '2026-07-10',
      ),
      Article(
        id: '6',
        title: {
          'en': 'Mental Health & Well-being',
          'bn': 'মানসিক স্বাস্থ্য ও সুস্থতা'
        },
        description: {
          'en': 'Managing stress and emotions during your pregnancy.',
          'bn': 'আপনার গর্ভাবস্থায় মানসিক চাপ এবং আবেগ পরিচালনা করা।'
        },
        content: {
          'en': 'It is normal to feel a range of emotions during pregnancy. Hormonal changes and the anticipation of a new baby can lead to stress or mood swings. Practicing mindfulness, getting enough sleep, and talking to loved ones can help maintain your mental well-being.',
          'bn': 'গর্ভাবস্থায় বিভিন্ন ধরণের আবেগ অনুভব করা স্বাভাবিক। হরমোনের পরিবর্তন এবং নতুন শিশুর আগমনের অপেক্ষা মানসিক চাপ বা মেজাজের পরিবর্তনের কারণ হতে পারে। মাইন্ডফুলনেস অনুশীলন করা, পর্যাপ্ত ঘুমানো এবং প্রিয়জনদের সাথে কথা বলা আপনার মানসিক সুস্থতা বজায় রাখতে সাহায্য করতে পারে।'
        },
        category: 'Mental Health',
        imageUrl: 'assets/images/pf14.jpg',
        readingTimeMinutes: 5,
        lastUpdated: '2026-07-28',
        tips: [
          'Practice deep breathing exercises.',
          'Talk openly about your feelings with your partner or a friend.',
          'Don\'t be afraid to ask for help with daily chores.',
          'Focus on things you can control.'
        ],
        warningSigns: [
          'Persistent feelings of sadness or hopelessness.',
          'Extreme anxiety that interferes with daily life.',
          'Inability to sleep even when tired.',
          'Thoughts of harming yourself or others.'
        ],
        contactDoctor: 'Talk to your doctor or a mental health professional if you feel overwhelmed or persistently sad.',
      ),
      Article(
        id: '7',
        title: {
          'en': 'Handling Pregnancy Emergencies',
          'bn': 'গর্ভাবস্থার জরুরি অবস্থা মোকাবিলা'
        },
        description: {
          'en': 'Knowing when to seek immediate medical help.',
          'bn': 'কখন অবিলম্বে চিকিৎসার সাহায্য নিতে হবে তা জানা।'
        },
        content: {
          'en': 'While most pregnancies proceed smoothly, it is vital to recognize signs that require immediate attention. Quick action can prevent complications for both you and your baby. Always have emergency contact numbers ready.',
          'bn': 'যদিও বেশিরভাগ গর্ভাবস্থা সুচারুভাবে সম্পন্ন হয়, তবুও অবিলম্বে মনোযোগ প্রয়োজন এমন লক্ষণগুলো চেনা অত্যন্ত গুরুত্বপূর্ণ। দ্রুত পদক্ষেপ নেওয়া আপনার এবং আপনার শিশুর উভয়ের জন্যই জটিলতা প্রতিরোধ করতে পারে। সর্বদা জরুরি যোগাযোগের নম্বরগুলো প্রস্তুত রাখুন।'
        },
        category: 'Emergency',
        imageUrl: 'assets/images/pf10.jpg',
        readingTimeMinutes: 6,
        lastUpdated: '2026-07-28',
        tips: [
          'Keep your hospital bag and medical records easily accessible.',
          'Save your doctor\'s and the nearest hospital\'s contact info.',
          'Know the quickest route to the emergency room.'
        ],
        warningSigns: [
          'Sudden swelling of the face, hands, or feet.',
          'Blurred vision or severe headaches.',
          'Absence or significant decrease in baby\'s movement.',
          'Water breaking early or premature contractions.'
        ],
        contactDoctor: 'Go to the nearest emergency room immediately if you experience any of these danger signs.',
      ),
      Article(
        id: '8',
        title: {
          'en': 'Safe Medication During Pregnancy',
          'bn': 'গর্ভাবস্থায় নিরাপদ ওষুধ'
        },
        description: {
          'en': 'What you need to know about taking medicine while expecting.',
          'bn': 'গর্ভবতী অবস্থায় ওষুধ খাওয়ার বিষয়ে আপনার যা জানা দরকার।'
        },
        content: {
          'en': 'Many medications can cross the placenta and affect your baby. Always consult your doctor before taking any over-the-counter drugs, herbal supplements, or prescription medicines. Some common medications are safe, while others must be avoided entirely.',
          'bn': 'অনেক ওষুধ প্লাসেন্টা অতিক্রম করে আপনার শিশুকে প্রভাবিত করতে পারে। যেকোনো ওভার-দ্য-কাউন্টার ওষুধ, ভেষজ সাপ্লিমেন্ট বা প্রেসক্রিপশন অনুযায়ী ওষুধ খাওয়ার আগে সর্বদা আপনার ডাক্তারের সাথে পরামর্শ করুন। কিছু সাধারণ ওষুধ নিরাপদ হলেও অন্যগুলো পুরোপুরি এড়িয়ে চলতে হবে।'
        },
        category: 'Medication',
        imageUrl: 'assets/images/pf12.jpg',
        readingTimeMinutes: 4,
        lastUpdated: '2026-07-28',
        tips: [
          'Make a list of all medications you were taking before pregnancy.',
          'Never stop prescribed medication without consulting your doctor.',
          'Be cautious with "natural" or herbal remedies.'
        ],
        warningSigns: [
          'Allergic reactions like rashes or breathing difficulty after taking a new medicine.',
          'Dizziness or unusual heart palpitations.'
        ],
        contactDoctor: 'Consult your obstetrician before taking even the most common pain relievers like Ibuprofen.',
      ),
      Article(
        id: '9',
        title: {
          'en': 'The Importance of Prenatal Checkups',
          'bn': 'প্রসবপূর্ব চেকআপের গুরুত্ব'
        },
        description: {
          'en': 'Why regular visits to your doctor are essential.',
          'bn': 'কেন আপনার ডাক্তারের কাছে নিয়মিত ভিজিট করা অপরিহার্য।'
        },
        content: {
          'en': 'Prenatal care is the healthcare you get while you are pregnant. Regular checkups allow your doctor to monitor your baby\'s development and catch potential problems early. These visits are also a great time to ask questions and prepare for childbirth.',
          'bn': 'প্রসবপূর্ব যত্ন হলো গর্ভাবস্থায় আপনি যে স্বাস্থ্যসেবা পান। নিয়মিত চেকআপ আপনার ডাক্তারকে আপনার শিশুর বিকাশ পর্যবেক্ষণ করতে এবং সম্ভাব্য সমস্যাগুলো দ্রুত শনাক্ত করতে সাহায্য করে। এই ভিজিটগুলো প্রশ্ন জিজ্ঞাসা করার এবং প্রসবের জন্য প্রস্তুতি নেওয়ারও একটি চমৎকার সময়।'
        },
        category: 'Checkups',
        imageUrl: 'assets/images/pf13.jpg',
        readingTimeMinutes: 5,
        lastUpdated: '2026-07-28',
        tips: [
          'Don\'t skip any scheduled appointments.',
          'Write down your questions before the visit.',
          'Bring your partner or a family member for support.',
          'Keep a record of your blood pressure and weight.'
        ],
        contactDoctor: 'Schedule your first prenatal visit as soon as you think you are pregnant.',
      ),
    ];
  }

  static List<FAQ> getFAQs() {
    return [
      FAQ(
        question: {
          'en': 'What does AI Risk Prediction mean?',
          'bn': 'এআই ঝুঁকি পূর্বাভাস বলতে কী বোঝায়?'
        },
        answer: {
          'en': 'Our AI analyzes your reported symptoms and medical history to predict potential pregnancy risks based on established medical patterns.',
          'bn': 'আমাদের এআই আপনার রিপোর্ট করা উপসর্গ এবং চিকিৎসার ইতিহাস বিশ্লেষণ করে প্রতিষ্ঠিত মেডিকেল প্যাটার্নের ভিত্তিতে সম্ভাব্য গর্ভাবস্থার ঝুঁকির পূর্বাভাস দেয়।'
        },
        category: 'App Features',
      ),
      FAQ(
        question: {
          'en': 'Is this app a replacement for a doctor?',
          'bn': 'এই অ্যাপটি কি ডাক্তারের বিকল্প?'
        },
        answer: {
          'en': 'No, this app provides educational information and analysis but is NOT a replacement for professional medical advice, diagnosis, or treatment.',
          'bn': 'না, এই অ্যাপটি শিক্ষামূলক তথ্য এবং বিশ্লেষণ প্রদান করে তবে এটি পেশাদার চিকিৎসা পরামর্শ, রোগ নির্ণয় বা চিকিৎসার বিকল্প নয়।'
        },
        category: 'Medical',
      ),
      FAQ(
        question: {
          'en': 'How is my pregnancy week calculated?',
          'bn': 'আমার গর্ভাবস্থার সপ্তাহ কীভাবে গণনা করা হয়?'
        },
        answer: {
          'en': 'It is calculated based on the date of your last menstrual period (LMP) or your estimated due date (EDD) provided in your profile.',
          'bn': 'এটি আপনার শেষ মাসিকের তারিখ (LMP) অথবা আপনার প্রোফাইলে দেওয়া সম্ভাব্য প্রসবের তারিখ (EDD) এর ভিত্তিতে গণনা করা হয়।'
        },
        category: 'Calculation',
      ),
      FAQ(
        question: {
          'en': 'What should I do if I receive High Risk?',
          'bn': 'আমি যদি উচ্চ ঝুঁকির রিপোর্ট পাই তবে আমার কী করা উচিত?'
        },
        answer: {
          'en': 'If the app indicates a high risk, stay calm but contact your healthcare provider immediately for a clinical evaluation.',
          'bn': 'যদি অ্যাপটি উচ্চ ঝুঁকি নির্দেশ করে, তবে শান্ত থাকুন এবং অবিলম্বে ক্লিনিকাল মূল্যায়নের জন্য আপনার স্বাস্থ্যসেবা প্রদানকারীর সাথে যোগাযোগ করুন।'
        },
        category: 'Emergency',
      ),
      FAQ(
        question: {
          'en': 'Can I use the app offline?',
          'bn': 'আমি কি অফলাইনে অ্যাপটি ব্যবহার করতে পারি?'
        },
        answer: {
          'en': 'Basic features like local guides and symptom tracking are available offline, but AI analysis and syncing require an internet connection.',
          'bn': 'স্থানীয় গাইড এবং উপসর্গ ট্র্যাকিংয়ের মতো মৌলিক ফিচারগুলো অফলাইনে পাওয়া যায়, তবে এআই বিশ্লেষণ এবং সিঙ্কিংয়ের জন্য ইন্টারনেট সংযোগ প্রয়োজন।'
        },
        category: 'App Features',
      ),
      FAQ(
        question: {
          'en': 'Is my health information secure?',
          'bn': 'আমার স্বাস্থ্য তথ্য কি নিরাপদ?'
        },
        answer: {
          'en': 'Yes, we use advanced encryption and secure servers to ensure your personal health data is protected and kept private.',
          'bn': 'হ্যাঁ, আপনার ব্যক্তিগত স্বাস্থ্য তথ্য সুরক্ষিত এবং গোপন রাখা নিশ্চিত করতে আমরা উন্নত এনক্রিপশন এবং নিরাপদ সার্ভার ব্যবহার করি।'
        },
        category: 'Privacy',
      ),
      FAQ(
        question: {
          'en': 'How do appointment reminders work?',
          'bn': 'অ্যাপয়েন্টমেন্ট রিমাইন্ডার কীভাবে কাজ করে?'
        },
        answer: {
          'en': 'You can add your checkup dates in the calendar, and the app will send you notifications before your scheduled visits.',
          'bn': 'আপনি ক্যালেন্ডারে আপনার চেকআপের তারিখগুলো যোগ করতে পারেন এবং অ্যাপটি আপনার নির্ধারিত ভিজিটের আগে আপনাকে বিজ্ঞপ্তি পাঠাবে।'
        },
        category: 'App Features',
      ),
      FAQ(
        question: {
          'en': 'How do emergency alerts work?',
          'bn': 'জরুরি সতর্কতা কীভাবে কাজ করে?'
        },
        answer: {
          'en': 'In an emergency, you can tap the emergency button to quickly alert your saved contacts with your location information.',
          'bn': 'জরুরি অবস্থায় আপনি আপনার অবস্থানের তথ্যসহ আপনার সেভ করা কন্টাক্টগুলোকে দ্রুত সতর্ক করতে জরুরি বোতামে ট্যাপ করতে পারেন।'
        },
        category: 'Safety',
      ),
      FAQ(
        question: {
          'en': 'Can I change the language?',
          'bn': 'আমি কি ভাষা পরিবর্তন করতে পারি?'
        },
        answer: {
          'en': 'Yes, you can switch between English and Bangla in the settings menu at any time.',
          'bn': 'হ্যাঁ, আপনি যেকোনো সময় সেটিংস মেনুতে ইংরেজি এবং বাংলার মধ্যে পরিবর্তন করতে পারেন।'
        },
        category: 'Settings',
      ),
      FAQ(
        question: {
          'en': 'Can I update my medical history?',
          'bn': 'আমি কি আমার চিকিৎসার ইতিহাস আপডেট করতে পারি?'
        },
        answer: {
          'en': 'Yes, you can edit your medical profile under the Profile section to keep your information up to date.',
          'bn': 'হ্যাঁ, আপনার তথ্য আপ টু ডেট রাখতে আপনি প্রোফাইল সেকশনের অধীনে আপনার মেডিকেল প্রোফাইল এডিট করতে পারেন।'
        },
        category: 'Profile',
      ),
      FAQ(
        question: {
          'en': 'How often should I report symptoms?',
          'bn': 'আমার কত ঘন ঘন উপসর্গ রিপোর্ট করা উচিত?'
        },
        answer: {
          'en': 'We recommend reporting daily or whenever you experience a change in your well-being for better AI accuracy.',
          'bn': 'উন্নত এআই নির্ভুলতার জন্য আমরা প্রতিদিন বা যখনই আপনি আপনার সুস্থতার পরিবর্তন অনুভব করেন তখনই রিপোর্ট করার পরামর্শ দিই।'
        },
        category: 'Health',
      ),
      FAQ(
        question: {
          'en': 'What symptoms should I enter?',
          'bn': 'আমার কোন উপসর্গগুলো প্রবেশ করানো উচিত?'
        },
        answer: {
          'en': 'Report any physical changes like nausea, headache, swelling, or fetal movement changes.',
          'bn': 'বমি বমি ভাব, মাথাব্যথা, ফোলাভাব বা ভ্রূণের নড়াচড়ার পরিবর্তনের মতো যেকোনো শারীরিক পরিবর্তন রিপোর্ট করুন।'
        },
        category: 'Health',
      ),
      FAQ(
        question: {
          'en': 'What does Medium Risk mean?',
          'bn': 'মাঝারি ঝুঁকি বলতে কী বোঝায়?'
        },
        answer: {
          'en': 'Medium risk suggests some concern. You should monitor your symptoms closely and discuss them with your doctor at your next visit.',
          'bn': 'মাঝারি ঝুঁকি কিছুটা উদ্বেগের ইঙ্গিত দেয়। আপনার উপসর্গগুলো নিবিড়ভাবে পর্যবেক্ষণ করা উচিত এবং আপনার পরবর্তী ভিজিটে সেগুলো আপনার ডাক্তারের সাথে আলোচনা করা উচিত।'
        },
        category: 'Emergency',
      ),
      FAQ(
        question: {
          'en': 'What should I do in an emergency?',
          'bn': 'জরুরি অবস্থায় আমার কী করা উচিত?'
        },
        answer: {
          'en': 'Call your local emergency number or go to the nearest hospital immediately. Do not wait for the app analysis.',
          'bn': 'অবিলম্বে আপনার স্থানীয় জরুরি নম্বরে কল করুন বা নিকটস্থ হাসপাতালে যান। অ্যাপ বিশ্লেষণের জন্য অপেক্ষা করবেন না।'
        },
        category: 'Safety',
      ),
      FAQ(
        question: {
          'en': 'Can I edit my profile?',
          'bn': 'আমি কি আমার প্রোফাইল এডিট করতে পারি?'
        },
        answer: {
          'en': 'Yes, go to the Profile tab to edit your name, age, and pregnancy details.',
          'bn': 'হ্যাঁ, আপনার নাম, বয়স এবং গর্ভাবস্থার বিবরণ এডিট করতে প্রোফাইল ট্যাবে যান।'
        },
        category: 'Profile',
      ),
      FAQ(
        question: {
          'en': 'How does AI analyze symptoms?',
          'bn': 'এআই কীভাবে উপসর্গ বিশ্লেষণ করে?'
        },
        answer: {
          'en': 'It uses machine learning models trained on large datasets of maternal health records to identify patterns indicating risk.',
          'bn': 'এটি ঝুঁকির ইঙ্গিতবাহী প্যাটার্নগুলো শনাক্ত করতে মাতৃত্বকালীন স্বাস্থ্য রেকর্ডের বিশাল ডেটাসেটে প্রশিক্ষিত মেশিন লার্নিং মডেল ব্যবহার করে।'
        },
        category: 'App Features',
      ),
      FAQ(
        question: {
          'en': 'Does the app save my history?',
          'bn': 'অ্যাপটি কি আমার ইতিহাস সেভ করে?'
        },
        answer: {
          'en': 'Yes, your reporting history is saved so you can track your health trends over time.',
          'bn': 'হ্যাঁ, আপনার রিপোর্টিং ইতিহাস সেভ করা থাকে যাতে আপনি সময়ের সাথে সাথে আপনার স্বাস্থ্যের প্রবণতা ট্র্যাক করতে পারেন।'
        },
        category: 'Privacy',
      ),
      FAQ(
        question: {
          'en': 'Can I share reports with doctors?',
          'bn': 'আমি কি ডাক্তারের সাথে রিপোর্ট শেয়ার করতে পারি?'
        },
        answer: {
          'en': 'Yes, you can generate a summary report of your symptoms to show your doctor during consultations.',
          'bn': 'হ্যাঁ, কনসালটেশনের সময় আপনার ডাক্তারকে দেখানোর জন্য আপনি আপনার উপসর্গের একটি সংক্ষিপ্ত রিপোর্ট তৈরি করতে পারেন।'
        },
        category: 'App Features',
      ),
      FAQ(
        question: {
          'en': 'Is the app free?',
          'bn': 'অ্যাপটি কি ফ্রি?'
        },
        answer: {
          'en': 'Basic educational and tracking features are free. Some advanced AI features may require a premium subscription.',
          'bn': 'মৌলিক শিক্ষামূলক এবং ট্র্যাকিং ফিচারগুলো ফ্রি। কিছু উন্নত এআই ফিচারের জন্য প্রিমিয়াম সাবস্ক্রিপশন প্রয়োজন হতে পারে।'
        },
        category: 'Settings',
      ),
      FAQ(
        question: {
          'en': 'How accurate is the AI prediction?',
          'bn': 'এআই পূর্বাভাস কতটা নির্ভুল?'
        },
        answer: {
          'en': 'While highly accurate based on data, it is a screening tool only and should always be verified by a medical professional.',
          'bn': 'ডেটার ভিত্তিতে অত্যন্ত নির্ভুল হলেও এটি কেবল একটি স্ক্রিনিং টুল এবং সর্বদা একজন চিকিৎসা পেশাদার দ্বারা যাচাই করা উচিত।'
        },
        category: 'Medical',
      ),
    ];
  }
}
