// ignore_for_file: sized_box_for_whitespace

import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';

import 'state.dart';
export 'state.dart';

class ReportComponent extends Component<ReportState> {
  ReportComponent()
      : super(
          view: (ReportState state, Dispatch dispatch, ComponentContext<ReportState> ctx) {
            //return Container(height: 100, child: Text('${state.toString()}'));

            return Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                color: Colors.blue,
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      child: const Icon(Icons.report),
                    ),
                    Text(
                      'Total ${state.total} tasks, ${state.done} done.',
                      style: const TextStyle(fontSize: 18.0, color: Colors.white),
                    )
                  ],
                ));
          },
        );
}
