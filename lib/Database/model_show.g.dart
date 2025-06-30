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
      id: fields[0] as String,
      name: fields[1] as String,
      thumbnailUrl: fields[2] as String,
      artworkUrl: fields[3] as String,
      rating: fields[4] as String,
      releaseStatus: fields[5] as String,
      firstAir: fields[6] as String,
      lastAir: fields[7] as String,
      episodesNum: fields[8] as int,
      seasonsNum: fields[9] as int,
      genres: (fields[10] as List).cast<String>(),
      overview: fields[11] as String,
      seasonsNames: (fields[12] as List).cast<String>(),
      seasonsThumbnailsUrls: (fields[13] as List).cast<String>(),
      seasonsAirDates: (fields[14] as List).cast<String>(),
      seasonsEpisodeCounts: (fields[15] as List).cast<int>(),
      seasonsOverviews: (fields[16] as List).cast<String>(),
      seasonsRatings: (fields[17] as List).cast<String>(),
      castNames: (fields[18] as List).cast<String>(),
      castImageUrls: (fields[19] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Show obj) {
    writer
      ..writeByte(20)
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
      ..write(obj.releaseStatus)
      ..writeByte(6)
      ..write(obj.firstAir)
      ..writeByte(7)
      ..write(obj.lastAir)
      ..writeByte(8)
      ..write(obj.episodesNum)
      ..writeByte(9)
      ..write(obj.seasonsNum)
      ..writeByte(10)
      ..write(obj.genres)
      ..writeByte(11)
      ..write(obj.overview)
      ..writeByte(12)
      ..write(obj.seasonsNames)
      ..writeByte(13)
      ..write(obj.seasonsThumbnailsUrls)
      ..writeByte(14)
      ..write(obj.seasonsAirDates)
      ..writeByte(15)
      ..write(obj.seasonsEpisodeCounts)
      ..writeByte(16)
      ..write(obj.seasonsOverviews)
      ..writeByte(17)
      ..write(obj.seasonsRatings)
      ..writeByte(18)
      ..write(obj.castNames)
      ..writeByte(19)
      ..write(obj.castImageUrls);
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
