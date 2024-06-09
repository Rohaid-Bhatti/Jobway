import 'package:flutter/material.dart';
import 'package:flutter_job_portal/global.dart';

class DetailsScreen extends StatelessWidget {
  final int id;

  const DetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 2,
              child: Image.network(
                "https://cdn.pixabay.com/photo/2015/01/08/18/26/write-593333_960_720.jpg",
                fit: BoxFit.cover,
                color: Colors.black38,
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_outline_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height / 1.3,
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Text(
                          "${jobList[id].title}",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Center(
                        child: Text(
                          "${jobList[id].location}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.apply(color: Colors.grey),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          Text(
                            "Lahore",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        "Job Description",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        "${jobList[id].description}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.grey),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        "Responsibility",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        "${jobList[id].responsibility}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.grey),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        "Photos",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: jobList[id].photos.length,
                          itemBuilder: (ctx, i) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 9.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child:
                                    Image.network("${jobList[id].photos[i]}"),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.height * .7,
                        height: 45,
                        child: ElevatedButton(
                          child: Text(
                            "Apply Now",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.apply(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
