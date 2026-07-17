
import 'package:flutter/material.dart';
import 'package:client_pilot/pages/client_detail_page.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  int selectedTaskFilter = 0; // Due today (default)

  final List<Map<String, String>> todayJobs = [
    {'name': 'Marcus Webb',    'service': 'Lawn Mowing',        'time': '8:00 AM',  'price': '\$85',  'status': 'Paid',    'phone': '555-111-2222', 'email': 'marcus@example.com',  'schedule': 'Every Monday',    'address': '12 Oak Lane',       'notes': 'Gate code is 1234. Dog in backyard — keep closed.'},
    {'name': 'Sandra Torres',  'service': 'Hedge Trimming',     'time': '10:30 AM', 'price': '\$65',  'status': 'Paid',    'phone': '555-333-4444', 'email': 'sandra@example.com',  'schedule': 'Every Wednesday', 'address': '88 Maple Ave',      'notes': 'Prefers contact by text only.'},
    {'name': 'Derek Liu',      'service': 'Lawn Mowing + Edging','time': '1:00 PM', 'price': '\$120', 'status': 'Pending', 'phone': '555-555-6666', 'email': 'derek@example.com',   'schedule': 'Every Friday',    'address': '5 Birchwood Ct',    'notes': ''},
    {'name': 'Brenda Okafor',  'service': 'Leaf Cleanup',       'time': '3:30 PM',  'price': '\$55',  'status': 'Pending', 'phone': '555-777-8888', 'email': 'brenda@example.com',  'schedule': 'Bi-weekly',       'address': '200 Elm Street',    'notes': 'Invoice sent — waiting on check.'},
    {'name': 'Tom Harrington', 'service': 'Lawn Mowing',        'time': '5:00 PM',  'price': '\$75',  'status': 'Overdue', 'phone': '555-999-0000', 'email': 'tomh@example.com',    'schedule': 'Every Tuesday',   'address': '77 Ridgeline Rd',   'notes': 'Called twice — no response. Try again Friday.'},
  ];

  final List<Map<String, String>> overdueClients = [
    {'name': 'Tom Harrington', 'days': '14 days overdue', 'amount': '\$75',  'status': 'Overdue', 'phone': '555-999-0000', 'email': 'tomh@example.com',   'service': 'Lawn Mowing', 'schedule': 'Every Tuesday', 'address': '77 Ridgeline Rd',  'notes': 'Called twice — no response. Try again Friday.'},
    {'name': 'Karen Mills',    'days': '9 days overdue',  'amount': '\$90',  'status': 'Overdue', 'phone': '555-222-3333', 'email': 'karen@example.com',  'service': 'Cleanup',     'schedule': 'Monthly',       'address': '31 Sunset Blvd',   'notes': 'Left voicemail. Follow up by end of week.'},
    {'name': 'Phil Gentry',    'days': '30 days no service', 'amount': '\$0','status': 'Overdue', 'phone': '555-444-5555', 'email': 'phil@example.com',   'service': 'Lawn Mowing', 'schedule': 'Inactive',      'address': '9 Clearwater Dr',  'notes': 'Has not booked in 30 days. Reach out to re-engage.'},
  ];

  final List<Map<String, String>> paymentStatus = [
    {'name': 'Marcus Webb',   'service': 'Lawn Mowing',    'amount': '\$85',  'status': 'Paid',    'phone': '555-111-2222', 'email': 'marcus@example.com',  'schedule': 'Every Monday',    'address': '12 Oak Lane',     'notes': 'Gate code is 1234. Dog in backyard — keep closed.'},
    {'name': 'Sandra Torres', 'service': 'Hedge Trimming', 'amount': '\$65',  'status': 'Paid',    'phone': '555-333-4444', 'email': 'sandra@example.com',  'schedule': 'Every Wednesday', 'address': '88 Maple Ave',    'notes': 'Prefers contact by text only.'},
    {'name': 'Derek Liu',     'service': 'Lawn + Edging',  'amount': '\$120', 'status': 'Pending', 'phone': '555-555-6666', 'email': 'derek@example.com',   'schedule': 'Every Friday',    'address': '5 Birchwood Ct',  'notes': ''},
    {'name': 'Brenda Okafor', 'service': 'Leaf Cleanup',   'amount': '\$55',  'status': 'Pending', 'phone': '555-777-8888', 'email': 'brenda@example.com',  'schedule': 'Bi-weekly',       'address': '200 Elm Street',  'notes': 'Invoice sent — waiting on check.'},
    {'name': 'Tom Harrington','service': 'Lawn Mowing',    'amount': '\$75',  'status': 'Overdue', 'phone': '555-999-0000', 'email': 'tomh@example.com',    'schedule': 'Every Tuesday',   'address': '77 Ridgeline Rd', 'notes': 'Called twice — no response. Try again Friday.'},
    {'name': 'Karen Mills',   'service': 'Cleanup',        'amount': '\$90',  'status': 'Overdue', 'phone': '555-222-3333', 'email': 'karen@example.com',   'schedule': 'Monthly',         'address': '31 Sunset Blvd',  'notes': 'Left voicemail. Follow up by end of week.'},
  ];

  Widget _buildPaymentTile(Map<String, String> payment) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientDetailPage(client: payment),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: payment['status'] == 'Paid'
                  ? Color(0xFF4ADE80).withValues(alpha: 0.12)
                  : payment['status'] == 'Pending'
                    ? Color(0xFFF59E0B).withValues(alpha: 0.12)
                    : Color(0xFFF87171).withValues(alpha: 0.12),
                child: Text(
                  getInitials(payment['name']!),
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: payment['status'] == 'Paid'
                      ? Color(0xFF4ADE80)
                      : payment['status'] == 'Pending'
                        ? Color(0xFFF59E0B)
                        : Color(0xFFF87171),
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment['name']!,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(payment['service']!,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(payment['amount']!,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: payment['status'] == 'Paid'
                    ? Color(0xFF4ADE80)
                    : payment['status'] == 'Pending'
                      ? Color(0xFFF59E0B)
                      : Color(0xFFF87171),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Gets initials from 'Tom Harrington' → 'TH'
  String getInitials(String name) {
    List<String> parts = name.split(' ');
    return parts[0][0] + parts[1][0];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Row(
                  children: [
                    Expanded(child: 
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedTaskFilter = 0; // Due Today
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(3.0),
                          padding: EdgeInsets.all(8.0),
                          //width: 120,
                          height: 85,
                          decoration: 
                            BoxDecoration(
                              color: Color(0xFF4ADE80).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 10.0,
                                  offset: Offset(5.0, 5.0)
                                )
                              ]
                            ),
                            child: 
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('Due Today',
                                      style: TextStyle(
                                        color: Color(0xFF4ADE80),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.task_outlined,
                                        color: Color(0xFF4ADE80),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Text('0',
                                    style: TextStyle(
                                      color: Color(0xFF4ADE80),
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                    Expanded(child: 
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedTaskFilter = 1; //Due Soon
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(3.0),
                          padding: EdgeInsets.all(8.0),
                          //width: 120,
                          height: 85,
                          decoration: 
                            BoxDecoration(
                              color: Color(0xFFF59E0B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 10.0,
                                  offset: Offset(5.0, 5.0)
                                ),
                              ],
                            ),
                          child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('Due Soon',
                                      style: TextStyle(
                                        color: Color(0xFFF59E0B),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.hourglass_top_outlined,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Text('1',
                                    style: TextStyle(
                                      color: Color(0xFFF59E0B),
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                    Expanded(child: 
                    InkWell (
                      onTap: () {
                        setState(() {
                          selectedTaskFilter = 2;
                        });
                      }, // Due Later
                      child: Container(
                        margin: EdgeInsets.all(3.0),
                        padding: EdgeInsets.all(8.0),
                        //width: 120,
                        height: 85,
                        decoration: 
                          BoxDecoration(
                            color: Color(0xFFF87171).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 10.0,
                                offset: Offset(5.0, 5.0)
                              )
                            ]
                          ),
                          child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('Past Due',
                                      style: TextStyle(
                                        color: Color(0xFFF87171),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.warning_amber,
                                        color: Color(0xFFF87171),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Text('2',
                                    style: TextStyle(
                                      color: Color(0xFFF87171),
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                ],
              ),


      // REVENUE THIS MONTH * ACTIVE CLIENTS * JOBS TODAY * OVERDUE PAYMENTS


            Column(
              children: [
                // First row - top 2 cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(3.0),
                        padding: EdgeInsets.all(10.0),
                        height: 95,
                        decoration: BoxDecoration(
                          color: Color(0xFF13161E),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10.0,
                              offset: Offset(5.0, 5.0)
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$4,280',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //SizedBox(height: 1.0),
                            Text('Revenue This Month',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12.0,
                              ),
                            ),
                            Text('^ +12%',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF4ADE80),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(3.0),
                        padding: EdgeInsets.all(10.0),
                        height: 95,
                        decoration: BoxDecoration(
                          color: Color(0xFF13161E),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10.0,
                              offset: Offset(5.0, 5.0)
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('38',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //SizedBox(height: 8.0),
                            Text('Active Clients',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12.0,
                              ),
                            ),
                            Text('^ 3 new',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF4ADE80),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Second row - bottom 2 cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(3.0),
                        padding: EdgeInsets.all(10.0),
                        height: 95,
                        decoration: BoxDecoration(
                          color: Color(0xFF13161E),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10.0,
                              offset: Offset(5.0, 5.0)
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('7',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //SizedBox(height: 8.0),
                            Text('Jobs Today',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12.0,
                              ),
                            ),
                            Text('^ 3 jobs completed',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF4ADE80),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(3.0),
                        padding: EdgeInsets.all(10.0),
                        height: 95,
                        decoration: BoxDecoration(
                          color: Color(0xFF13161E),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10.0,
                              offset: Offset(5.0, 5.0)
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$640',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                //color: Color(0xFFF87171),
                              ),
                            ),
                            //SizedBox(height: 8.0),
                            Text('Overdue Payments',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12.0,
                              ),
                            ),
                            Text('^ 4 clients pending',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFFF87171),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            /*                    SECCTION: TODAY'S SCHEDULE                  */

            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Today\'s Schedule',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('7 jobs • 4 remaining',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text('View All',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF4ADE80),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    color: Color(0xFF252836),
                    thickness: 1.0,
                    height: 1.0,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [

                        // .asMap() converts the list into a map of {index: item}
                        // .entries gives us each {key: index, value: job} pair
                        // this lets us know WHICH position we are at in the loop
                        // which we need so we can skip the divider on the last item
                        ...todayJobs.asMap().entries.map((entry) {
                          final index = entry.key;   // the position number (0, 1, 2...)
                          final job = entry.value;   // the actual job map data
                          
                          // checks if this is the last item in the list
                          // todayJobs.length - 1 is the index of the last item
                          final isLast = index == todayJobs.length - 1;

                          return Column(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClientDetailPage(client: job),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 52.0, // fixed width so all times line up
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(job['time']!.split(' ')[0], // gets '8:00' from '8:00 AM'
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                              Text(job['time']!.split(' ')[1], // gets 'AM' from '8:00 AM'
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(job['name']!,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 3.0),
                                            Text(job['service']!,
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(job['price']!,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                              decoration: BoxDecoration(
                                                color: job['status'] == 'Paid'
                                                  ? Color(0xFF4ADE80).withValues(alpha: 0.12)
                                                  : job['status'] == 'Pending'
                                                    ? Color(0xFFF59E0B).withValues(alpha: 0.12)
                                                    : Color(0xFFF87171).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              child: Text(job['status']!,
                                                style: TextStyle(
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: job['status'] == 'Paid'
                                                    ? Color(0xFF4ADE80)
                                                    : job['status'] == 'Pending'
                                                      ? Color(0xFFF59E0B)
                                                      : Color(0xFFF87171),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // if (!isLast) is an inline conditional in Flutter
                              // it only renders the Divider widget if this is NOT the last item
                              // this prevents an ugly trailing divider at the bottom of the list
                              if (!isLast)
                                Divider(
                                  color: Color(0xFF252836),
                                  thickness: 1.0,
                                  height: 1.0,
                                ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.0),
                ],
              ),
            ),

            /**                   SECTION: PAYMENT STATUS                         */

            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Payment Status',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('April 2026',            /*        TO-DO: MAKE DATE NON-CONSTANT         */
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text('View All',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF4ADE80),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.0,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: .0),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF4ADE80).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Row(
                            children: [
                              // PAID CHIP
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.0),
                              Text('Paid: 26',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: Color(0xFF4ADE80),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.0),
                    
                        // PENDING CHIP
                    
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.0),
                              Text('Pending: 8',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: Color(0xFFF59E0B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.0),
                    
                        // OVERDUE CHIP
                    
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFF87171).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF87171),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.0),
                              Text('Overdue: 4',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: Color(0xFFF87171),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ], 
                    ),
                  ),

                  SizedBox(height: 12.0),
                  Divider(
                    color: Color(0xFF252836),
                    thickness: 1.0,
                    height: 1.0,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                       // OVERDUE SECTION
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text('Overdue',
                          style: TextStyle(
                            fontSize: 11.0,
                            color: Color(0xFFF87171),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ...paymentStatus.where((p) => p['status'] == 'Overdue').map((payment) {
                        return _buildPaymentTile(payment);
                      }).toList(),

                      Divider(color: Color(0xFF252836), thickness: 1.0, height: 16.0),

                      // PENDING SECTION
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Text('Pending',
                          style: TextStyle(
                            fontSize: 11.0,
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ...paymentStatus.where((p) => p['status'] == 'Pending').map((payment) {
                        return _buildPaymentTile(payment);
                      }).toList(),

                      Divider(color: Color(0xFF252836), thickness: 1.0, height: 16.0),

                      // PAID SECTION
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Text('Recently Paid',
                          style: TextStyle(
                            fontSize: 11.0,
                            color: Color(0xFF4ADE80),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ...paymentStatus.where((p) => p['status'] == 'Paid').map((payment) {
                        return _buildPaymentTile(payment);
                      }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /*                    SECTION: NEEDS ATTENTION                  */

            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Needs Attention',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Follow up required',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Text('View All',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Color(0xFF4ADE80),
                        ),
                      ),
                    ],
                  ),
                  ...overdueClients.map((client) {
                    return Column(
                      children: [
                        Divider(
                          color: Color(0xFF252836),
                          thickness: 1.0,
                          height: 8.0,
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClientDetailPage(client: client),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(0xFFF87171).withValues(alpha: 0.12),
                                    child: Text(
                                      getInitials(client['name']!),
                                      style: TextStyle(
                                        color: Color(0xFFF87171),
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(client['name']!,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(client['days']!,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Color(0xFFF87171),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Text(client['amount']!,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF87171),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}