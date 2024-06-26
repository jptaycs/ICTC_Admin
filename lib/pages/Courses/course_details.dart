import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ictc_admin/models/course.dart';
import 'package:ictc_admin/models/register.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CourseDetails extends StatefulWidget {
  const CourseDetails({super.key, required this.course, this.register});

  final Course course;
  final Register? register;

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  late final Future<List<Register>> courseStudents;
  late Future<String?> receiptUrl = getImageUrl();

  Future<String?> getImageUrl([String? path]) async {
    try {
      final url = await Supabase.instance.client.storage
          .from('receipts')
          .createSignedUrl('${widget.register?.id}/image.png', 60);
      return url;
    } catch (e) {
      return null;
    }
  }
  

  @override
  void initState() {
    courseStudents = Supabase.instance.client
        .from('registration')
        .select()
        .eq('course_id', widget.course.id!)
        .withConverter((data) {
      return data.map((e) => Register.fromJson(e)).toList();
    });

    super.initState();
    // print(courseStudents.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff19306B),
      appBar: AppBar(
        title: const Text('Course Details'),
        backgroundColor: const Color(0xff19306B),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: buildBody(context),
    );
  }

  

  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Text(
                  widget.course.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(

                  height: 14,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "P${widget.course.cost.toString()} ",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "| ${widget.course.endDate!.difference(widget.course.startDate!).inDays} days (${widget.course.endDate!.difference(widget.course.startDate!).inHours} hours)",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Chip(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      label: Text(
                        "Schedule: ${DateFormat.yMMMMd().format(widget.course.startDate!)} - ${DateFormat.yMMMMd().format(widget.course.endDate!)} ",
                        style: const TextStyle(
                            color: Color(0xff153faa),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Chip(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      label: Text(
                        "Venue: ${widget.course.venue}",
                        style: const TextStyle(
                            color: Color(0xff153faa),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Chip(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      label: Text(
                        "Evaluation: ${widget.course.evalink}",
                        style: const TextStyle(
                            color: Color(0xff153faa),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  width: 800,
                  height: 100,
                  child: Center(
                    child: Text(
                      "${widget.course.description}",
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<Register>>(
            future: courseStudents,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No students in this course',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
              } else {
                return Container(
                  color: const Color(0xfff1f5fb),
                  child: DataTable2(
                      dataRowColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08);
                        }
                        return Colors.white;
                      }),
                      showCheckboxColumn: false,
                      sortAscending: false,
                      bottomMargin: 90,
                      isVerticalScrollBarVisible: true,
                      minWidth: 600,
                      horizontalMargin: 100,
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Receipts')),
                        DataColumn(label: Text('Billing Status')),
                        DataColumn(label: Text('Payment Status')),
                        DataColumn(label: Text('Attendance Status')),
                        DataColumn(label: Text('Evaluation Status')), // TODO: New ongoing and pending boolean for evalStatus
                        DataColumn(label: Text('Certificate Status')), //TODO: Query if paymentStatus == true && evalStatus == true, then certificateStatus = true
                      ],
                      rows: snapshot.data!
                          .map((register) => buildRow(register))
                          .toList()),
                );
              }
            },
          ),
        ),
      ],
    );
  }
  Widget receiptButton(Register register) {
    return Material(
            color: Colors.black12,
            child: InkWell(
              splashColor: Colors.black26,
              onTap: () async {
                // Select an image
                final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom, allowedExtensions: ['png']);

                if (result == null || result.files.isEmpty) {
                  return;
                }

                final file = result.files.first;
                final bytes = file.bytes;
                final extension = file.extension;

                if (bytes == null || extension == null) {
                  return;
                }

                // Upload image to Supabase
                final supa = Supabase.instance.client;
                final path = "${register.id}/image.$extension";

                await supa.storage
                    .from('receipts')
                    .uploadBinary(path, bytes,
                        fileOptions: const FileOptions(upsert: true))
                    .whenComplete(() {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Image uploaded successfully!")));

                  setState(() {
                    receiptUrl = getImageUrl(path);
                  });
                });
              },
              child: Container(
                color: Colors.transparent,
                height: 40,
                width: MediaQuery.of(context).size.width * 0.2,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Upload Image",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
  DataRow2 buildRow(Register register) {  
    final studentId = register.studentId;

    return DataRow2(
      onSelectChanged: (selected) {},
      cells: [
        DataCell(
          FutureBuilder(
            future: Supabase.instance.client
                .from('student')
                .select('first_name, last_name')
                .eq('id', studentId)
                .single()
                .then((response) {
              final firstName = response['first_name'] as String;
              final lastName = response['last_name'] as String;
              final fullName = '$firstName $lastName';
              return fullName;
            }),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Text(snapshot.data ?? '');
              }
            },
          ),
        ),
        DataCell(FutureBuilder(
          future: Supabase.instance.client
              .from('student')
              .select('email')
              .eq('id', studentId)
              .single()
              .then((response) {
            final email = response['email'] as String;
            return email;
          }),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();

            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text(snapshot.data ?? '');
            }
          },
        )),
        DataCell(
          receiptButton(register)
        ),

        
        
        DataCell( //Billing
          ToggleSwitch(
            minWidth: 90.0,
            cornerRadius: 20.0,
            activeBgColors: [
              [Color(0xff008744)!],
              [Color(0xffffa700)!]
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.white,
            inactiveFgColor: Color(0xff153faa).withOpacity(0.5),
            initialLabelIndex: register.bill ? 0 : 1,
            totalSwitches: 2,
            labels: ['', ''],
            icons: [Icons.check, Icons.close],
            radiusStyle: true,
            onToggle: (index) {
              setState(() {
                register.bill = index == 0;
              });

              final updatedData = {
                'bill_status': register.bill
              }; // Update column name if needed

              Supabase.instance.client
                  .from('registration')
                  .update(updatedData)
                  .eq('id', register.id as Object)
                  .then((_) {
                // Update succeeded
                print('Status updated successfully');
              }).catchError((error) {
                // Handle update error
                print('Error updating status: $error');
              });
            },
          ),
        ),

        DataCell( //Payment
          ToggleSwitch(
            minWidth: 90.0,
            cornerRadius: 20.0,
            activeBgColors: [
              [Color(0xff008744)!],
              [Color(0xffffa700)!]
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.white,
            inactiveFgColor: Color(0xff153faa).withOpacity(0.5),
            initialLabelIndex: register.status ? 0 : 1,
            totalSwitches: 2,
            labels: ['', ''],
            icons: [Icons.check, Icons.close],
            radiusStyle: true,
            onToggle: (index) {
              setState(() {
                register.status = index == 0;
              });

              final updatedData = {
                'is_approved': register.status
              }; // Update column name if needed

              Supabase.instance.client
                  .from('registration')
                  .update(updatedData)
                  .eq('id', register.id as Object)
                  .then((_) {
                // Update succeeded
                print('Status updated successfully');
              }).catchError((error) {
                // Handle update error
                print('Error updating status: $error');
              });
            },
          ),
        ),
        DataCell( //attendance
          ToggleSwitch(
            minWidth: 90.0,
            cornerRadius: 20.0,
            activeBgColors: [
              [Color(0xff008744)!],
              [Color(0xffffa700)!]
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.white,
            inactiveFgColor: Color(0xff153faa).withOpacity(0.5),
            initialLabelIndex: register.attend ? 0 : 1,
            totalSwitches: 2,
            labels: ['', ''],
            icons: [Icons.check, Icons.close],
            radiusStyle: true,
            onToggle:  (index) {
              setState(() {
                register.attend = index == 0;
              });

              final updatedData = {
                'attend_status': register.attend
              }; // Update column name if needed

              Supabase.instance.client
                  .from('registration')
                  .update(updatedData)
                  .eq('id', register.id as Object)
                  .then((_) {
                // Update succeeded
                print('Status updated successfully');
              }).catchError((error) {
                // Handle update error
                print('Error updating status: $error');
              });
            },
          ),
        ),
        DataCell( //eval
          ToggleSwitch(
            minWidth: 90.0,
            cornerRadius: 20.0,
            activeBgColors: [
              [Color(0xff008744)!],
              [Color(0xffffa700)!]
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.white,
            inactiveFgColor: Color(0xff153faa).withOpacity(0.5),
            initialLabelIndex: register.eval ? 0 : 1,
            totalSwitches: 2,
            labels: ['', ''],
            icons: [Icons.check, Icons.close],
            radiusStyle: true,
            onToggle:  (index) {
              setState(() {
                register.eval = index == 0;
              });

              final updatedData = {
                'eval_status': register.eval
              }; // Update column name if needed

              Supabase.instance.client
                  .from('registration')
                  .update(updatedData)
                  .eq('id', register.id as Object)
                  .then((_) {
                // Update succeeded
                print('Status updated successfully');
              }).catchError((error) {
                // Handle update error
                print('Error updating status: $error');
              });
            },
          ),
        ),
        DataCell( //certificate
          ToggleSwitch(
            minWidth: 90.0,
            cornerRadius: 20.0,
            activeBgColors: [
              [Color(0xff008744)!],
              [Color(0xffffa700)!]
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.white,
            inactiveFgColor: Color(0xff153faa).withOpacity(0.5),
            initialLabelIndex: register.cert ? 0 : 1,
            totalSwitches: 2,
            labels: ['', ''],
            icons: [Icons.check, Icons.close],
            radiusStyle: true,
            onToggle:  (index) {
              setState(() {
                register.cert = index == 0;
              });

              final updatedData = {
                'cert_status': register.cert
              }; // Update column name if needed

              Supabase.instance.client
                  .from('registration')
                  .update(updatedData)
                  .eq('id', register.id as Object)
                  .then((_) {
                // Update succeeded
                print('Status updated successfully');
              }).catchError((error) {
                // Handle update error
                print('Error updating status: $error');
              });
            },
          ),
        ),
      ],
    );
  }
}