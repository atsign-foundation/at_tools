enum OperationEnum {
  update,
  delete,
  append,
  remove
}

String getOperationName(OperationEnum d) => '$d'.split('.').last;