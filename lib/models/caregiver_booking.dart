class CaregiverBooking {
  final String id;
  final BookingMother? mother;
  final String caregiverId;
  final DateTime startDate;
  final DateTime endDate;
  final String shift;
  final String? accommodation;
  final double totalAmount;
  final String? address;
  final String? notes;
  final String status; // pending, accepted, rejected, cancelled, completed
  final BookingReview? review;
  final DateTime createdAt;

  CaregiverBooking({
    required this.id,
    this.mother,
    required this.caregiverId,
    required this.startDate,
    required this.endDate,
    required this.shift,
    this.accommodation,
    required this.totalAmount,
    this.address,
    this.notes,
    required this.status,
    this.review,
    required this.createdAt,
  });

  factory CaregiverBooking.fromJson(Map<String, dynamic> json) {
    return CaregiverBooking(
      id: json['_id'] ?? '',
      mother: json['mother'] != null
          ? BookingMother.fromJson(json['mother'])
          : null,
      caregiverId: json['caregiver'] is String
          ? json['caregiver']
          : json['caregiver']?['_id'] ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      shift: json['shift'] ?? 'day',
      accommodation: json['accommodation'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      address: json['address'],
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      review: json['review'] != null
          ? BookingReview.fromJson(json['review'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
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

  int get durationDays {
    return endDate.difference(startDate).inDays + 1;
  }
}

class BookingMother {
  final String id;
  final String name;
  final String phoneNo;
  final String? address;

  BookingMother({
    required this.id,
    required this.name,
    required this.phoneNo,
    this.address,
  });

  factory BookingMother.fromJson(Map<String, dynamic> json) {
    return BookingMother(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      address: json['address'],
    );
  }
}

class BookingReview {
  final int rating;
  final String? comment;
  final DateTime? reviewDate;

  BookingReview({
    required this.rating,
    this.comment,
    this.reviewDate,
  });

  factory BookingReview.fromJson(Map<String, dynamic> json) {
    return BookingReview(
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      reviewDate: json['review_date'] != null
          ? DateTime.parse(json['review_date'])
          : null,
    );
  }
}
