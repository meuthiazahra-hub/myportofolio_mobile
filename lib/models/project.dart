import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    this.id,
    required this.title,
    required this.description,
    required this.techStack,
    required this.projectUrl,
    this.projectImageUrl = '',
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;
  final String techStack;
  final String projectUrl;

  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  @JsonKey(defaultValue: 0)
  final int starCount;

  @JsonKey(defaultValue: false)
  final bool isStarred;

  @JsonKey(defaultValue: '')
  final String starredByNames;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
