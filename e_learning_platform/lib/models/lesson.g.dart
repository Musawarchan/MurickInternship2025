// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final int typeId = 2;

  @override
  Lesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      id: fields[0] as String,
      courseId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      type: fields[4] as LessonType,
      contentUrl: fields[5] as String,
      duration: fields[6] as int,
      order: fields[7] as int,
      isPreview: fields[8] as bool,
      resources: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.contentUrl)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.order)
      ..writeByte(8)
      ..write(obj.isPreview)
      ..writeByte(9)
      ..write(obj.resources);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonProgressAdapter extends TypeAdapter<LessonProgress> {
  @override
  final int typeId = 3;

  @override
  LessonProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonProgress(
      lessonId: fields[0] as String,
      userId: fields[1] as String,
      progress: fields[2] as double,
      isCompleted: fields[3] as bool,
      lastWatched: fields[4] as DateTime,
      watchTime: fields[5] as int,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LessonProgress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.progress)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.lastWatched)
      ..writeByte(5)
      ..write(obj.watchTime)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CourseProgressAdapter extends TypeAdapter<CourseProgress> {
  @override
  final int typeId = 4;

  @override
  CourseProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseProgress(
      courseId: fields[0] as String,
      userId: fields[1] as String,
      overallProgress: fields[2] as double,
      completedLessons: fields[3] as int,
      totalLessons: fields[4] as int,
      lastAccessed: fields[5] as DateTime,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CourseProgress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.courseId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.overallProgress)
      ..writeByte(3)
      ..write(obj.completedLessons)
      ..writeByte(4)
      ..write(obj.totalLessons)
      ..writeByte(5)
      ..write(obj.lastAccessed)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonTypeAdapter extends TypeAdapter<LessonType> {
  @override
  final int typeId = 1;

  @override
  LessonType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LessonType.video;
      case 1:
        return LessonType.pdf;
      case 2:
        return LessonType.text;
      case 3:
        return LessonType.quiz;
      default:
        return LessonType.video;
    }
  }

  @override
  void write(BinaryWriter writer, LessonType obj) {
    switch (obj) {
      case LessonType.video:
        writer.writeByte(0);
        break;
      case LessonType.pdf:
        writer.writeByte(1);
        break;
      case LessonType.text:
        writer.writeByte(2);
        break;
      case LessonType.quiz:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
