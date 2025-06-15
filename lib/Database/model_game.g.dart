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
      id: fields[0] as String,
      name: fields[1] as String,
      thumbnailUrl: fields[2] as String,
      artworkUrl: fields[3] as String,
      rating: fields[4] as String,
      releaseDate: fields[5] as String,
      developer: fields[6] as String,
      genres: (fields[7] as List).cast<String>(),
      overview: fields[8] as String,
      timeHaste: fields[9] as String,
      timeNormal: fields[10] as String,
      timeComplete: fields[11] as String,
      expansions: (fields[12] as List).cast<String>(),
      dlcs: (fields[13] as List).cast<String>(),
      similarGames: (fields[14] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.artworkUrl)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.releaseDate)
      ..writeByte(6)
      ..write(obj.developer)
      ..writeByte(7)
      ..write(obj.genres)
      ..writeByte(8)
      ..write(obj.overview)
      ..writeByte(9)
      ..write(obj.timeHaste)
      ..writeByte(10)
      ..write(obj.timeNormal)
      ..writeByte(11)
      ..write(obj.timeComplete)
      ..writeByte(12)
      ..write(obj.expansions)
      ..writeByte(13)
      ..write(obj.dlcs)
      ..writeByte(14)
      ..write(obj.similarGames);
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
