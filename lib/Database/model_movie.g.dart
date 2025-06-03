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
      name: fields[0] as String,
      thumbnailUrl: fields[1] as String,
      rating: fields[2] as double,
      releaseStatus: fields[3] as String,
      genres: (fields[4] as List).cast<String>(),
      overview: fields[5] as String,
      budget: fields[6] as String,
      revenue: fields[7] as String,
      status: fields[8] as String,
      userRating: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.thumbnailUrl)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.releaseStatus)
      ..writeByte(4)
      ..write(obj.genres)
      ..writeByte(5)
      ..write(obj.overview)
      ..writeByte(6)
      ..write(obj.budget)
      ..writeByte(7)
      ..write(obj.revenue)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.userRating);
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
