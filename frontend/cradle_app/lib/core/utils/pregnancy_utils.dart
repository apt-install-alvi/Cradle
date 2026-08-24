class ChildSize {
  final String nameEn;
  final String nameBn;
  final String icon;

  ChildSize({required this.nameEn, required this.nameBn, required this.icon});
}

ChildSize getChildSizeForWeek(int week) {
  final Map<int, ChildSize> sizes = {
    4: ChildSize(nameEn: "poppy seed", nameBn: "পোস্ত দানা", icon: "poppy"),
    5: ChildSize(nameEn: "apple seed", nameBn: "আপেলের বীজ", icon: "seed"),
    6: ChildSize(nameEn: "sweet pea", nameBn: "মিষ্টি মটরশুঁটি", icon: "pea"),
    7: ChildSize(nameEn: "blueberry", nameBn: "ব্লুবেরি", icon: "blueberry"),
    8: ChildSize(nameEn: "grape", nameBn: "আঙুর", icon: "grape"),
    9: ChildSize(nameEn: "strawberry", nameBn: "স্ট্রবেরি", icon: "strawberry"),
    10: ChildSize(nameEn: "kumquat", nameBn: "কামকুয়াট", icon: "kumquat"),
    11: ChildSize(nameEn: "fig", nameBn: "ডুমুর", icon: "fig"),
    12: ChildSize(nameEn: "lime", nameBn: "লেবু", icon: "lime"),
    13: ChildSize(nameEn: "pea pod", nameBn: "মটরশুঁটি", icon: "pea_pod"),
    14: ChildSize(nameEn: "lemon", nameBn: "লেবু", icon: "lemon"),
    15: ChildSize(nameEn: "apple", nameBn: "আপেল", icon: "apple"),
    16: ChildSize(nameEn: "avocado", nameBn: "অ্যাভোকাডো", icon: "avocado"),
    17: ChildSize(nameEn: "onion", nameBn: "পেঁয়াজ", icon: "onion"),
    18: ChildSize(nameEn: "bell pepper", nameBn: "ক্যাপসিকাম", icon: "pepper"),
    19: ChildSize(nameEn: "heirloom tomato", nameBn: "টমেটো", icon: "tomato"),
    20: ChildSize(nameEn: "banana", nameBn: "কলা", icon: "banana"),
    21: ChildSize(nameEn: "pomegranate", nameBn: "ডালিম", icon: "pomegranate"),
    22: ChildSize(nameEn: "papaya", nameBn: "পেঁপে", icon: "papaya"),
    23: ChildSize(nameEn: "grapefruit", nameBn: "বাতাবি লেবু", icon: "grapefruit"),
    24: ChildSize(nameEn: "cantaloupe", nameBn: "ফুটি", icon: "cantaloupe"),
    25: ChildSize(nameEn: "cauliflower", nameBn: "ফুলকপি", icon: "cauliflower"),
    26: ChildSize(nameEn: "lettuce", nameBn: "লেটুস", icon: "lettuce"),
    27: ChildSize(nameEn: "zucchini", nameBn: "ধুন্দল", icon: "zucchini"),
    28: ChildSize(nameEn: "eggplant", nameBn: "বেগুন", icon: "eggplant"),
    29: ChildSize(nameEn: "butternut squash", nameBn: "মিষ্টি কুমড়া", icon: "squash"),
    30: ChildSize(nameEn: "cabbage", nameBn: "বাঁধাকপি", icon: "cabbage"),
    31: ChildSize(nameEn: "coconut", nameBn: "নারকেল", icon: "coconut"),
    32: ChildSize(nameEn: "jicama", nameBn: "শাকআলু", icon: "jicama"),
    33: ChildSize(nameEn: "pineapple", nameBn: "আনারস", icon: "pineapple"),
    34: ChildSize(nameEn: "cantaloupe", nameBn: "ফুটি", icon: "cantaloupe"),
    35: ChildSize(nameEn: "honeydew melon", nameBn: "তরমুজ", icon: "melon"),
    36: ChildSize(nameEn: "romaine lettuce", nameBn: "লেটুস", icon: "lettuce"),
    37: ChildSize(nameEn: "swiss chard", nameBn: "পালং শাক", icon: "chard"),
    38: ChildSize(nameEn: "leek", nameBn: "লিক", icon: "leek"),
    39: ChildSize(nameEn: "watermelon", nameBn: "তরমুজ", icon: "watermelon"),
    40: ChildSize(nameEn: "pumpkin", nameBn: "মিষ্টি কুমড়া", icon: "pumpkin"),
  };

  if (week < 4) return ChildSize(nameEn: "tiny seed", nameBn: "ছোট বীজ", icon: "seed");
  if (week > 40) return sizes[40]!;
  return sizes[week] ?? sizes[8]!;
}
