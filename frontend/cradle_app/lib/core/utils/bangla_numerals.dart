String toBanglaDigits(dynamic value) {
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  return value
      .toString()
      .split('')
      .map((char) {
        final index = en.indexOf(char);
        return index == -1 ? char : bn[index];
      })
      .join();
}