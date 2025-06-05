// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 0;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      userName: fields[0] as String,
      email: fields[1] as String,
      listGames: (fields[2] as Map).cast<String, UserMediaEntry>(),
      listShows: (fields[3] as Map).cast<String, UserMediaEntry>(),
      listMovies: (fields[4] as Map).cast<String, UserMediaEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.listGames)
      ..writeByte(3)
      ..write(obj.listShows)
      ..writeByte(4)
      ..write(obj.listMovies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MediaEntryAdapter extends TypeAdapter<UserMediaEntry> {
  @override
  final int typeId = 1;

  @override
  UserMediaEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserMediaEntry(
      name: fields[0] as String,
      rating: fields[1] as double,
      status: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserMediaEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.rating)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
