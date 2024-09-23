import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallingDetailsPage extends StatelessWidget {
  void _makecall(String number)async
  {

    var url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url))
    {
      await launchUrl(url);
    }
    else
    {
      throw 'Could not launch $url';
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calling Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Call for a book a table!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _makecall('1234567890');
              },
              child: Text('Call Now'),
            ),
          ],
        ),
      ),
    );
  }
}
