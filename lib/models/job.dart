class JobModel {
  final String description, responsibility, iconUrl, location, salary, title;
  final List<String> photos;

  JobModel(
      {required this.description,
      required this.responsibility,
      required this.iconUrl,
      required this.location,
      required this.salary,
      required this.title,
      required this.photos});
}
