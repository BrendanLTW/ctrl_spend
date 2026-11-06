/// Icon keys a category can use (DESIGN §8). The database stores the key,
/// never an icon code point. Users pick from the first twelve; [wallet] is
/// for the built-in Salary category (Category manager design).
enum CategoryIconKey {
  food,
  coffee,
  car,
  bag,
  bolt,
  film,
  heart,
  gift,
  book,
  travel,
  home,
  phone,
  wallet,
}

/// Colour keys a category can use (DESIGN §3.3). Users pick from the first
/// seven; [neutral] is for built-in categories such as Gifts.
enum CategoryColorKey {
  orange,
  blue,
  pink,
  yellow,
  purple,
  green,
  red,
  neutral,
}
