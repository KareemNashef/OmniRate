// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_show.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShowAdapter extends TypeAdapter<Show> {
  @override
  final int typeId = 3;

  @override
  Show read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Show(
      name: fields[0] as String,
      thumbnailUrl: fields[1] as String,
      artworkUrl: fields[17] as String,
      rating: fields[2] as double,
      releaseStatus: fields[3] as String,
      firstAir: fields[4] as String,
      lastAir: fields[5] as String,
      episodesNum: fields[6] as int,
      seasonsNum: fields[7] as int,
      genres: (fields[8] as List).cast<String>(),
      overview: fields[9] as String,
      seasonsNames: (fields[10] as List).cast<String>(),
      seasonsThumbnailsUrls: (fields[11] as List).cast<String>(),
      seasonsAirDates: (fields[12] as List).cast<String>(),
      seasonsEpisodeCounts: (fields[13] as List).cast<int>(),
      seasonsOverviews: (fields[14] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Show obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.thumbnailUrl)
      ..writeByte(17)
      ..write(obj.artworkUrl)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.releaseStatus)
      ..writeByte(4)
      ..write(obj.firstAir)
      ..writeByte(5)
      ..write(obj.lastAir)
      ..writeByte(6)
      ..write(obj.episodesNum)
      ..writeByte(7)
      ..write(obj.seasonsNum)
      ..writeByte(8)
      ..write(obj.genres)
      ..writeByte(9)
      ..write(obj.overview)
      ..writeByte(10)
      ..write(obj.seasonsNames)
      ..writeByte(11)
      ..write(obj.seasonsThumbnailsUrls)
      ..writeByte(12)
      ..write(obj.seasonsAirDates)
      ..writeByte(13)
      ..write(obj.seasonsEpisodeCounts)
      ..writeByte(14)
      ..write(obj.seasonsOverviews);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
