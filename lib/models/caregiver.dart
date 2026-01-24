class Caregiver {
  final String id;
  final String userId;
  final String name;
  final String phoneNo;
  final int age;
  final int experienceYears;
  final String? about;
  final String shift; // wholeday, day, night
  final double amount;
  final double rating;
  final int totalReviews;
  final bool isApproved;
  final bool availability;
  final DateTime createdAt;

  Caregiver({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNo,
    required this.age,
    required this.experienceYears,
    this.about,
    required this.shift,
    required this.amount,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isApproved = false,
    this.availability = true,
    required this.createdAt,
  });

  factory Caregiver.fromJson(Map<String, dynamic> json) {
    return Caregiver(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      age: json['age'] ?? 0,
      experienceYears: json['experience_years'] ?? 0,
      about: json['about'],
      shift: json['shift'] ?? 'day',
      amount: (json['amount'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      isApproved: json['isApproved'] ?? false,
      availability: json['availability'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_no': phoneNo,
      'age': age,
      'experience_years': experienceYears,
      'about': about,
      'shift': shift,
      'amount': amount,
      'availability': availability,
    };
  }

  String get shiftDisplay {
    switch (shift) {
      case 'wholeday':
        return 'Whole Day';
      case 'day':
        return 'Day Shift';
      case 'night':
        return 'Night Shift';
      default:
        return shift;
    }
  }
}
