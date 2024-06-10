import 'package:flutter/material.dart';

import 'batch_widget.dart';
import '../data_model.dart';

class BatchPageView extends StatefulWidget {
  final List<Batch> batches;

  const BatchPageView({Key? key, required this.batches}) : super(key: key);

  @override
  _BatchPageViewState createState() => _BatchPageViewState();
}

class _BatchPageViewState extends State<BatchPageView> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.182,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.batches.length,
            itemBuilder: (context, index) {
              return BatchListItem(batch: widget.batches[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.batches.length,
                (int index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 10.0,
              width: _currentPage == index ? 30.0 : 10.0,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: _currentPage == index ? Colors.lightGreen : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
