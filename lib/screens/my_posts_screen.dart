import 'package:flutter/material.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // ========================================
    // ข้อมูลโพสต์ตัวอย่าง
    // ========================================

    final List<Map<String, String>> posts = [

      {
        'title': 'โทรศัพท์มือถือหาย',

        'location': 'อาคารเรียน A',

        'date': '01/10/2026',

        'status': 'กำลังตามหา',
      },

      {
        'title': 'กระเป๋าสตางค์หาย',

        'location': 'โรงอาหารมหาวิทยาลัย',

        'date': '28/09/2026',

        'status': 'กำลังตามหา',
      },

      {
        'title': 'กุญแจรถหาย',

        'location': 'ลานจอดรถ',

        'date': '25/09/2026',

        'status': 'พบแล้ว',
      },
    ];

    // ========================================
    // UI
    // ========================================

    return Scaffold(

      // ======================================
      // AppBar
      // ======================================

      appBar: AppBar(
        title: const Text(
          'โพสต์ของฉัน',

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      // ======================================
      // Body
      // ======================================

      body: posts.isEmpty

          // ไม่มีโพสต์
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.article_outlined,

                    size: 70,

                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'ยังไม่มีโพสต์',

                    style: TextStyle(
                      fontSize: 18,

                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )

          // มีโพสต์
          : ListView.builder(

              padding:
                  const EdgeInsets.all(16),

              itemCount:
                  posts.length,

              itemBuilder:
                  (context, index) {

                final post =
                    posts[index];

                return Card(

                  margin:
                      const EdgeInsets.only(
                    bottom: 16,
                  ),

                  elevation: 2,

                  child: Padding(

                    padding:
                        const EdgeInsets.all(16),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // ======================
                        // รูปภาพ
                        // ======================

                        Container(

                          width:
                              double.infinity,

                          height: 160,

                          decoration:
                              BoxDecoration(

                            color:
                                Colors.grey[200],

                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),

                          child: const Icon(
                            Icons.image,

                            size: 60,

                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        // ======================
                        // ชื่อโพสต์
                        // ======================

                        Text(
                          post['title']!,

                          style:
                              const TextStyle(
                            fontSize: 20,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        // ======================
                        // สถานที่
                        // ======================

                        Row(
                          children: [

                            const Icon(
                              Icons.location_on,

                              size: 20,

                              color: Colors.red,
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Expanded(
                              child: Text(
                                post['location']!,

                                style:
                                    const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        // ======================
                        // วันที่
                        // ======================

                        Row(
                          children: [

                            const Icon(
                              Icons.calendar_today,

                              size: 18,

                              color: Colors.grey,
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Text(
                              post['date']!,

                              style:
                                  const TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        // ======================
                        // สถานะ
                        // ======================

                        Row(
                          children: [

                            const Icon(
                              Icons.info_outline,

                              size: 18,

                              color:
                                  Colors.orange,
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Text(
                              post['status']!,

                              style:
                                  const TextStyle(
                                color:
                                    Colors.orange,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        // ======================
                        // ปุ่มดูรายละเอียด
                        // ======================

                        SizedBox(
                          width:
                              double.infinity,

                          height: 45,

                          child:
                              OutlinedButton(

                            onPressed: () {

                              ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'หน้ารายละเอียดโพสต์กำลังพัฒนา',
                                  ),
                                ),
                              );
                            },

                            child: const Text(
                              'ดูรายละเอียด',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}