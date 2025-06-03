// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_game.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 4;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Game(
      name: fields[0] as String,
      thumbnailUrl: fields[1] as String,
      artworkUrl: fields[12] as String,
      rating: fields[2] as double,
      releaseDate: fields[3] as String,
      developer: fields[4] as String,
      genres: (fields[5] as List).cast<String>(),
      overview: fields[6] as String,
      timeHaste: fields[7] as String,
      timeNormal: fields[8] as String,
      timeComplete: fields[9] as String,
      status: fields[10] as String,
      userRating: fields[11] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.thumbnailUrl)
      ..writeByte(12)
      ..write(obj.artworkUrl)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.releaseDate)
      ..writeByte(4)
      ..write(obj.developer)
      ..writeByte(5)
      ..write(obj.genres)
      ..writeByte(6)
      ..write(obj.overview)
      ..writeByte(7)
      ..write(obj.timeHaste)
      ..writeByte(8)
      ..write(obj.timeNormal)
      ..writeByte(9)
      ..write(obj.timeComplete)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.userRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
