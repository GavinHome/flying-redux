import 'package:flying_redux/flying_redux.dart';
import 'package:flutter/material.dart';
import 'state.dart';

class ReportComponent extends Component<ReportState> {
  ReportComponent()
      : super(
          view: (ReportState state, Dispatch dispatch,
              ComponentContext<ReportState> ctx) {
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
                      style:
                          const TextStyle(fontSize: 18.0, color: Colors.white),
                    )
                  ],
                ));
          },
        );
}
