import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ictc_admin/models/trainee.dart';
import 'package:ictc_admin/models/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TraineeViewMore extends StatefulWidget {
  final Trainee trainee;

  const TraineeViewMore({required this.trainee, super.key});

  @override
  State<TraineeViewMore> createState() => _TraineeViewMoreState();
}

class _TraineeViewMoreState extends State<TraineeViewMore> {
  late final Future<List<Register>> courseStudents;

  Future<String?> getAvatarUrl() async {
    try {
      final path = '${widget.trainee.uuid}/avatar.png';

      print(path);
      final url = await Supabase.instance.client.storage
          .from('avatars')
          .createSignedUrl(path, 60);

      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> fetchCourseTitle(int courseId) async {
    final response = await Supabase.instance.client
        .from('course')
        .select('title')
        .eq('id', courseId)
        .single();

    if (response.isEmpty) {
      throw Exception('No course found with id: $courseId');
    }

    final title = response['title']?.toString();
    print('Fetched course title for courseId $courseId: $title');
    return title ?? 'Unknown Course';
  }

  @override
  void initState() {
    courseStudents = Supabase.instance.client
        .from('registration')
        .select()
        .eq('student_id', widget.trainee.id!)
        .withConverter((data) {
      print(data);
      return data.map((e) => Register.fromJson(e)).toList();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Register>>(
      future: courseStudents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Container(
            margin: const EdgeInsets.only(bottom: 20, top: 33.5, right: 12),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                traineeHeader(),
                const SizedBox(height: 8),
                const Divider(thickness: 0.5, color: Colors.black87),
                const SizedBox(height: 8),
                buildCourses(snapshot.data!),
                const Spacer(
                  flex: 2,
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget traineeHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 50, left: 25, right: 25, bottom: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: FutureBuilder(
                    future: getAvatarUrl(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final url = snapshot.data;
                      print(url);
                      return ClipOval(
                        child: url != null
                            ? Image.network(
                                url,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                widget.trainee.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Contact",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          size: 24,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Email",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(widget.trainee.email),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 24,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Phone",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(widget.trainee.contactNumber ?? 'No contact number'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCourses(List<Register> register) {
    return Flexible(
      flex: 8,
      child: Container(
        padding: const EdgeInsets.only(top: 0, left: 25, right: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Courses",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final registerItem = register[index];

                  return FutureBuilder<String>(
                    future: fetchCourseTitle(registerItem.courseId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return traineeCourseCard(snapshot.data!, registerItem.cert);
                      }
                    },
                  );
                },
                itemCount: register.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget traineeCourseCard(String courseTitle, bool certStatus) {
    Color borderColor = certStatus ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(0),
      child: SizedBox(
        width: 240,
        height: 60,
        child: Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.book, color: Colors.black, size: 20,),
                SizedBox(width: 15),
                Text(
                  courseTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
