class ChildSize {
  final String nameEn;
  final String nameBn;
  final String icon;

  ChildSize({required this.nameEn, required this.nameBn, required this.icon});
}

ChildSize getChildSizeForWeek(int week) {
final Map<int, ChildSize> sizes = {
  4: ChildSize(nameEn: "poppy seed", nameBn: "পোস্ত দানা", icon: "poppy"),
  5: ChildSize(nameEn: "apple seed", nameBn: "আপেলের বীজ", icon: "apple_seed"),
  6: ChildSize(nameEn: "sweet pea", nameBn: "মিষ্টি মটরশুঁটি", icon: "pea"),
  7: ChildSize(nameEn: "blueberry", nameBn: "ব্লুবেরি", icon: "blueberry"),
  8: ChildSize(nameEn: "grape", nameBn: "আঙুর", icon: "grape"),
  9: ChildSize(nameEn: "strawberry", nameBn: "স্ট্রবেরি", icon: "strawberry"),
  10: ChildSize(nameEn: "kumquat", nameBn: "কামকুয়াট", icon: "kumquat"),
  11: ChildSize(nameEn: "fig", nameBn: "ডুমুর", icon: "fig"),
  12: ChildSize(nameEn: "lime", nameBn: "কাগজি লেবু", icon: "lime"),
  13: ChildSize(nameEn: "green bean", nameBn: "শিম", icon: "bean"),
  14: ChildSize(nameEn: "lemon", nameBn: "লেবু", icon: "lemon"),
  15: ChildSize(nameEn: "apple", nameBn: "আপেল", icon: "apple"),
  16: ChildSize(nameEn: "avocado", nameBn: "অ্যাভোকাডো", icon: "avocado"),
  17: ChildSize(nameEn: "turnip", nameBn: "শালগম", icon: "turnip"),
  18: ChildSize(nameEn: "bell pepper", nameBn: "ক্যাপসিকাম", icon: "pepper"),
  19: ChildSize(nameEn: "tomato", nameBn: "টমেটো", icon: "tomato"),
  20: ChildSize(nameEn: "banana", nameBn: "কলা", icon: "banana"),
  21: ChildSize(nameEn: "carrot", nameBn: "গাজর", icon: "carrot"),
  22: ChildSize(nameEn: "snake gourd", nameBn: "চিচিঙ্গা", icon: "snake_gourd"),
  23: ChildSize(nameEn: "pomelo", nameBn: "জাম্বুরা", icon: "pomelo"),
  24: ChildSize(nameEn: "corn on the cob", nameBn: "ভুট্টা", icon: "corn"),
  25: ChildSize(nameEn: "cauliflower", nameBn: "ফুলকপি", icon: "cauliflower"),
  26: ChildSize(nameEn: "lettuce", nameBn: "লেটুস", icon: "lettuce"),
  27: ChildSize(nameEn: "kohlrabi", nameBn: "ওলকপি", icon: "kohlrabi"),
  28: ChildSize(nameEn: "eggplant", nameBn: "বেগুন", icon: "eggplant"),
  29: ChildSize(nameEn: "ash gourd", nameBn: "চালকুমড়া", icon: "ash_gourd"),
  30: ChildSize(nameEn: "cabbage", nameBn: "বাঁধাকপি", icon: "cabbage"),
  31: ChildSize(nameEn: "coconut", nameBn: "নারকেল", icon: "coconut"),
  32: ChildSize(nameEn: "taro root", nameBn: "কচু", icon: "taro"),
  33: ChildSize(nameEn: "pineapple", nameBn: "আনারস", icon: "pineapple"),
  34: ChildSize(nameEn: "cantaloupe", nameBn: "বাঙ্গি", icon: "cantaloupe"),
  35: ChildSize(nameEn: "papaya", nameBn: "পেঁপে", icon: "papaya"),
  36: ChildSize(nameEn: "raw jackfruit", nameBn: "কাঁচা কাঁঠাল", icon: "jackfruit"),
  37: ChildSize(nameEn: "mustard greens", nameBn: "সরিষা শাক", icon: "greens"),
  38: ChildSize(nameEn: "sugarcane", nameBn: "আখ", icon: "sugarcane"),
  39: ChildSize(nameEn: "mini watermelon", nameBn: "ছোট তরমুজ", icon: "watermelon"),
  40: ChildSize(nameEn: "pumpkin", nameBn: "কুমড়া", icon: "pumpkin"),
};

  if (week < 4) return ChildSize(nameEn: "tiny seed", nameBn: "ছোট বীজ", icon: "seed");
  if (week > 40) return sizes[40]!;
  return sizes[week] ?? sizes[8]!;
}
