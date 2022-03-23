class TodoItem {
  String title;
  bool done;

  TodoItem({required this.title, required this.done});

  toJSONEncodable() {
    Map<String, dynamic> m = {};

    m['title'] = title;
    m['done'] = done;

    return m;
  }
}