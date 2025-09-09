class ExpenseReminder {
  int? id;
  int vehicleId;
  String? expenseType;
  bool? isRecurring;
  bool? triggerKmEnabled;
  double? triggerKm;
  bool? triggerDateEnabled;
  DateTime? triggerDate;
  bool? recurringKmEnabled;
  int? recurringKmInterval;
  bool? recurringTimeEnabled;
  int? recurringDaysInterval;
  int? recurringMonthsInterval;
  int? recurringYearsInterval;
  DateTime createdAt;
  DateTime? updatedAt;

  ExpenseReminder({
    this.id,
    required this.vehicleId,
    this.expenseType,
    this.isRecurring,
    this.triggerKmEnabled,
    this.triggerKm,
    this.triggerDateEnabled,
    this.triggerDate,
    this.recurringKmEnabled,
    this.recurringKmInterval,
    this.recurringTimeEnabled,
    this.recurringDaysInterval,
    this.recurringMonthsInterval,
    this.recurringYearsInterval,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'expense_type': expenseType,
      'is_recurring': isRecurring == true ? 1 : 0,
      'trigger_km_enabled': triggerKmEnabled == true ? 1 : 0,
      'trigger_km': triggerKm,
      'trigger_date_enabled': triggerDateEnabled == true ? 1 : 0,
      'trigger_date': triggerDate?.toIso8601String(),
      'recurring_km_enabled': recurringKmEnabled == true ? 1 : 0,
      'recurring_km_interval': recurringKmInterval,
      'recurring_time_enabled': recurringTimeEnabled == true ? 1 : 0,
      'recurring_days_interval': recurringDaysInterval,
      'recurring_months_interval': recurringMonthsInterval,
      'recurring_years_interval': recurringYearsInterval,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ExpenseReminder.fromMap(Map<String, dynamic> map) {
    return ExpenseReminder(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      expenseType: map['expense_type'],
      isRecurring: map['is_recurring'] == 1,
      triggerKmEnabled: map['trigger_km_enabled'] == 1,
      triggerKm: map['trigger_km'],
      triggerDateEnabled: map['trigger_date_enabled'] == 1,
      triggerDate: map['trigger_date'] != null ? DateTime.parse(map['trigger_date']) : null,
      recurringKmEnabled: map['recurring_km_enabled'] == 1,
      recurringKmInterval: map['recurring_km_interval'],
      recurringTimeEnabled: map['recurring_time_enabled'] == 1,
      recurringDaysInterval: map['recurring_days_interval'],
      recurringMonthsInterval: map['recurring_months_interval'],
      recurringYearsInterval: map['recurring_years_interval'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}