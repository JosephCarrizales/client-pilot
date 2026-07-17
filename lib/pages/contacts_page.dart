import 'package:client_pilot/widgets/add_contact_form.dart';
import 'package:client_pilot/pages/client_detail_page.dart';
import 'package:flutter/material.dart';


class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {

  final List<Map<String, String>> clients = [
    {'name': 'Marcus Webb',    'service': 'Lawn Mowing',    'phone': '555-111-2222', 'email': 'marcus@example.com',  'schedule': 'Every Monday',    'price': '\$85',  'status': 'Paid',    'address': '12 Oak Lane',      'notes': 'Gate code is 1234. Dog in backyard — keep closed.'},
    {'name': 'Sandra Torres',  'service': 'Hedge Trimming', 'phone': '555-333-4444', 'email': 'sandra@example.com',  'schedule': 'Every Wednesday', 'price': '\$65',  'status': 'Paid',    'address': '88 Maple Ave',     'notes': 'Prefers contact by text only.'},
    {'name': 'Derek Liu',      'service': 'Lawn + Edging',  'phone': '555-555-6666', 'email': 'derek@example.com',   'schedule': 'Every Friday',    'price': '\$120', 'status': 'Pending', 'address': '5 Birchwood Ct',   'notes': ''},
    {'name': 'Brenda Okafor',  'service': 'Leaf Cleanup',   'phone': '555-777-8888', 'email': 'brenda@example.com',  'schedule': 'Bi-weekly',       'price': '\$55',  'status': 'Pending', 'address': '200 Elm Street',   'notes': 'Invoice sent — waiting on check.'},
    {'name': 'Tom Harrington', 'service': 'Lawn Mowing',    'phone': '555-999-0000', 'email': 'tomh@example.com',    'schedule': 'Every Tuesday',   'price': '\$75',  'status': 'Overdue', 'address': '77 Ridgeline Rd',  'notes': 'Called twice — no response. Try again Friday.'},
    {'name': 'Karen Mills',    'service': 'Cleanup',        'phone': '555-222-3333', 'email': 'karen@example.com',   'schedule': 'Monthly',         'price': '\$90',  'status': 'Overdue', 'address': '31 Sunset Blvd',   'notes': 'Left voicemail. Follow up by end of week.'},
  ];

  String _getInitials(String name) {
    // remove extra spaces and split by space
    List<String> parts = name.trim().split(' ');
    
    // if only one word, just return the first two letters
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    
    // if two or more words, return first letter of first and last word
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  String searchQuery = ''; // A search query variable to track what the user is typing

  List<Map<String, String>> get filteredClients { //A filtered list that only shows clients matching the search
    if (searchQuery.isEmpty) {
      return clients;
    }
    return clients.where((client) {
      return client['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            client['service']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [

          // 1. PAGE HEADER
          Padding(
            padding: EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: Row(
              children: [
                Text('Contacts',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text('${clients.length} total',           //TO DO: MAKE DYNAMIC
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // 2. SEARCH BAR + ADD BUTTON
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF13161E),
                   // borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Color(0xFF252836),
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value; // update searchQuery when the user types
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search clients...',
                      hintStyle: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14.0,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              GestureDetector(
                onTap: () async {
                  // await waits for the form to close and return data
                  final newClient = await Navigator.push(
                    context,
                      MaterialPageRoute(
                        builder: (context) => AddContactForm(),
                      ),
                    );
                    // if a client was returned, add it to the list
                    if (newClient != null) {
                      setState(() {
                        clients.add(newClient);
                      });
                    }
                },
                child: Container(
                  height: 45.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF4ADE80),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Color(0xFF0B0D12),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.0),

          // 3. CLIENT LIST
          Expanded(
            child: ListView.builder(
              itemCount: filteredClients.length,
              itemBuilder: (context, index) {
                final client = filteredClients[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF13161E),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Material(
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
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: client['status'] == 'Paid'
                                ? Color(0xFF4ADE80).withValues(alpha: 0.12)
                                : client['status'] == 'Pending'
                                  ? Color(0xFFF59E0B).withValues(alpha: 0.12)
                                  : Color(0xFFF87171).withValues(alpha: 0.12),
                              child: Text(
                                _getInitials(client['name']!),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: client['status'] == 'Paid'
                                    ? Color(0xFF4ADE80)
                                    : client['status'] == 'Pending'
                                      ? Color(0xFFF59E0B)
                                      : Color(0xFFF87171),
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
                                Text(client['service']!,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                Text(client['schedule']!,
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(client['price']!,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                  decoration: BoxDecoration(
                                    color: client['status'] == 'Paid'
                                      ? Color(0xFF4ADE80).withValues(alpha: 0.12)
                                      : client['status'] == 'Pending'
                                        ? Color(0xFFF59E0B).withValues(alpha: 0.12)
                                        : Color(0xFFF87171).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(client['status']!,
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: client['status'] == 'Paid'
                                        ? Color(0xFF4ADE80)
                                        : client['status'] == 'Pending'
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}