// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 2;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: fields[0] as String,
      name: fields[1] as String,
      thumbnailUrl: fields[2] as String,
      artworkUrl: fields[3] as String,
      rating: fields[4] as String,
      releaseStatus: fields[5] as String,
      genres: (fields[6] as List).cast<String>(),
      overview: fields[7] as String,
      budget: fields[8] as String,
      revenue: fields[9] as String,
      castNames: (fields[10] as List).cast<String>(),
      castImageUrls: (fields[11] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.genres)
      ..writeByte(7)
      ..write(obj.overview)
      ..writeByte(8)
      ..write(obj.budget)
      ..writeByte(9)
      ..write(obj.revenue)
      ..writeByte(10)
      ..write(obj.castNames)
      ..writeByte(11)
      ..write(obj.castImageUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
