import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:akanet/app/home_2/job_entries/entry_list_item.dart';
import 'package:akanet/app/home_2/job_entries/entry_page.dart';
import 'package:akanet/app/home_2/jobs/edit_job_page.dart';
import 'package:akanet/app/home_2/jobs/list_items_builder.dart';
import 'package:akanet/app/home_2/models/entry.dart';
import 'package:akanet/app/home_2/models/job.dart';
import 'package:akanet/common_widgets/show_exception_alert_dialog.dart';
import 'package:akanet/services/database.dart';

class JobEntriesPage extends StatelessWidget {
  const JobEntriesPage({
    @required this.database,
    this.job,
  });
  final Database database;
  final Job job;

  static Future<void> show(BuildContext context, Database database, Job job) async {
    // final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: false,
        builder: (context) => JobEntriesPage(
          database: database,
          job: job,
        ),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext context, Entry entry) async {
    try {
      await database.deleteEntry(entry);
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Operation failed',
        exception: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Job>(
        stream: database.jobStream(job: job),
        builder: (context, snapshot) {
          final job = snapshot.data;
          final jobName = job?.description ?? '';
          return Scaffold(
            appBar: AppBar(
              elevation: 2.0,
              title: Text(jobName),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () => EditJobPage.show(
                    context,
                    database: database,
                    job: job,
                  ),
                ),
                IconButton(
                    onPressed: () => EntryPage.show(
                          context: context,
                          database: database,
                          job: job,
                        ),
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    ))
              ],
            ),
            body: _buildContent(context, job),
          );
        });
  }

  Widget _buildContent(BuildContext context, Job job) {
    return StreamBuilder<List<Entry>>(
      stream: database.entriesStream(job: job),
      builder: (context, snapshot) {
        return ListItemsBuilder<Entry>(
          snapshot: snapshot,
          itemBuilder: (context, entry) {
            return DismissibleEntryListItem(
              key: Key('entry-${entry.id}'),
              entry: entry,
              job: job,
              onDismissed: () => _deleteEntry(context, entry),
              onTap: () => EntryPage.show(
                context: context,
                database: database,
                job: job,
                entry: entry,
              ),
            );
          },
        );
      },
    );
  }
}
