// ignore_for_file: sized_box_for_whitespace

import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';

import 'state.dart';
export 'state.dart';

class ReportComponent extends Component<ReportState> {
  ReportComponent()
      : super(
          view: (ReportState state, Dispatch dispatch, ComponentContext<ReportState> ctx) {
            return Container(height: 100, child: Text('${state.toString()}'));
          },
        );
}
