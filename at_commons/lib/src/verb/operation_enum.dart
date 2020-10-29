enum OperationEnum { update, delete }

String getOperationName(OperationEnum d) => '$d'.split('.').last;
