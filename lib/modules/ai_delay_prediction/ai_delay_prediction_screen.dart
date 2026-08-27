import 'dart:math';

import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

class AiDelayPredictionScreen extends StatefulWidget {
  const AiDelayPredictionScreen({super.key});

  @override
  State<AiDelayPredictionScreen> createState() =>
      _AiDelayPredictionScreenState();
}

class _AiDelayPredictionScreenState
    extends State<AiDelayPredictionScreen> {
  final List<String> _stations = [
    'KL Sentral',
    'Kelana Jaya',
    'Pasar Seni',
    'Masjid Jamek',
    'KLCC',
    'Ampang Park',
    'Taman Jaya',
    'Bangsar',
    'Universiti',
    'Asia Jaya',
    'Subang Jaya',
    'Putra Heights',
  ];

  String? _fromStation;
  String? _toStation;

  bool _loading = false;
  bool _hasPrediction = false;
  bool _showExplanation = false;

  int _riskScore = 0;
  int _expectedDelay = 0;

  String _riskLevel = '';
  String _weather = '';
  String _crowdLevel = '';

  Color get _riskColor {
    if (_riskScore >= 75) {
      return AppColors.critical;
    } else if (_riskScore >= 40) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  Future<void> _predictDelay() async {
    if (_fromStation == null || _toStation == null) {
      _showMessage(
        'Please select your origin and destination.',
      );
      return;
    }

    if (_fromStation == _toStation) {
      _showMessage(
        'Origin and destination cannot be the same.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _showExplanation = false;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    final random = Random();

    final risk = 25 + random.nextInt(66);
    final delay = risk < 40
        ? 1 + random.nextInt(3)
        : risk < 75
        ? 3 + random.nextInt(5)
        : 7 + random.nextInt(7);

    final weatherOptions = [
      'Clear',
      'Cloudy',
      'Light Rain',
      'Heavy Rain',
    ];

    final crowdOptions = [
      'Low',
      'Moderate',
      'Busy',
      'Very Busy',
    ];

    setState(() {
      _riskScore = risk;
      _expectedDelay = delay;

      _weather =
      weatherOptions[random.nextInt(weatherOptions.length)];

      _crowdLevel =
      crowdOptions[random.nextInt(crowdOptions.length)];

      if (_riskScore >= 75) {
        _riskLevel = 'HIGH RISK';
      } else if (_riskScore >= 40) {
        _riskLevel = 'MEDIUM RISK';
      } else {
        _riskLevel = 'LOW RISK';
      }

      _hasPrediction = true;
      _loading = false;
    });
  }

  void _clearPrediction() {
    setState(() {
      _fromStation = null;
      _toStation = null;

      _hasPrediction = false;
      _showExplanation = false;

      _riskScore = 0;
      _expectedDelay = 0;

      _riskLevel = '';
      _weather = '';
      _crowdLevel = '';
    });
  }

  void _swapStations() {
    setState(() {
      final temp = _fromStation;
      _fromStation = _toStation;
      _toStation = temp;

      _hasPrediction = false;
      _showExplanation = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'AI Delay Prediction',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _clearPrediction,
            tooltip: 'Clear',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            30,
          ),
          children: [
            const Text(
              'Plan Your Journey',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Select your route to check the predicted delay risk.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            _buildRouteSelector(),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed:
              _loading ? null : _predictDelay,
              icon: _loading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.auto_graph_rounded,
              ),
              label: Text(
                _loading
                    ? 'Analysing Route...'
                    : 'Predict Delay',
              ),
            ),

            if (!_hasPrediction && !_loading)
              _buildEmptyState(),

            if (_hasPrediction) ...[
              const SizedBox(height: 30),

              _buildSelectedRoute(),

              const SizedBox(height: 26),

              const Text(
                'Prediction Result',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 22),

              Center(
                child: _buildRiskCircle(),
              ),

              const SizedBox(height: 14),

              Text(
                _riskLevel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _riskColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.schedule_rounded,
                      title: 'Expected Delay',
                      value: '+$_expectedDelay min',
                      valueColor: _riskColor,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.cloud_rounded,
                      title: 'Weather',
                      value: _weather,
                      valueColor:
                      AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.groups_rounded,
                      title: 'Crowd Level',
                      value: _crowdLevel,
                      valueColor:
                      AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildInfoCard(
                      icon:
                      Icons.directions_transit_rounded,
                      title: 'Transport',
                      value: 'Rail',
                      valueColor:
                      AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _buildRecommendationCard(),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showExplanation =
                    !_showExplanation;
                  });
                },
                icon: Icon(
                  _showExplanation
                      ? Icons.expand_less_rounded
                      : Icons
                      .info_outline_rounded,
                  color: AppColors.gold,
                ),
                label: Text(
                  _showExplanation
                      ? 'Hide Explanation'
                      : 'Why this prediction?',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (_showExplanation) ...[
                const SizedBox(height: 14),
                _buildExplanationCard(),
              ],

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed:
                _loading ? null : _predictDelay,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Run Prediction Again',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelector() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          _buildStationDropdown(
            label: 'FROM',
            icon: Icons.trip_origin_rounded,
            value: _fromStation,
            hint: 'Select origin station',
            onChanged: (value) {
              setState(() {
                _fromStation = value;
                _hasPrediction = false;
              });
            },
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(
                child: Divider(
                  color: AppColors.divider,
                ),
              ),

              const SizedBox(width: 10),

              InkWell(
                onTap: _swapStations,
                borderRadius:
                BorderRadius.circular(30),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius:
                    BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: AppColors.gold,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Divider(
                  color: AppColors.divider,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildStationDropdown(
            label: 'TO',
            icon: Icons.location_on_rounded,
            value: _toStation,
            hint: 'Select destination station',
            onChanged: (value) {
              setState(() {
                _toStation = value;
                _hasPrediction = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStationDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius:
            BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: const TextStyle(
                  color:
                  AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              dropdownColor:
              AppColors.surface,
              icon: const Icon(
                Icons
                    .keyboard_arrow_down_rounded,
                color:
                AppColors.textSecondary,
              ),
              items: _stations.map(
                    (station) {
                  return DropdownMenuItem<String>(
                    value: station,
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color:
                          AppColors.gold,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            station,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding:
      const EdgeInsets.only(top: 45),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
              BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.gold,
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Ready to Predict',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Choose your origin and destination,\nthen tap Predict Delay.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedRoute() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.directions_transit_rounded,
            color: AppColors.gold,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Route',
                  style: TextStyle(
                    color:
                    AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$_fromStation → $_toStation',
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCircle() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _riskColor.withValues(
            alpha: 0.25,
          ),
          width: 14,
        ),
        boxShadow: [
          BoxShadow(
            color: _riskColor.withValues(
              alpha: 0.15,
            ),
            blurRadius: 28,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(
            color: _riskColor,
            width: 5,
          ),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Text(
              '$_riskScore%',
              style: TextStyle(
                color: _riskColor,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 3),

            const Text(
              'DELAY RISK',
              style: TextStyle(
                color:
                AppColors.textSecondary,
                fontSize: 11,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: AppColors.gold,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color:
              AppColors.textSecondary,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    String message;
    IconData icon;

    if (_riskScore >= 75) {
      message =
      'High delay risk detected. Consider leaving earlier or checking an alternative route.';
      icon = Icons.warning_amber_rounded;
    } else if (_riskScore >= 40) {
      message =
      'A short delay is possible. Allow an extra $_expectedDelay minutes for your journey.';
      icon = Icons.schedule_rounded;
    } else {
      message =
      'Your selected route currently has a low predicted delay risk.';
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _riskColor.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: _riskColor,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommendation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  message,
                  style: const TextStyle(
                    color:
                    AppColors.textSecondary,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Why is the risk $_riskScore%?',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          _ReasonRow(
            icon: Icons.cloud_rounded,
            text:
            'Current weather condition: $_weather. Weather conditions can affect travel and waiting times.',
          ),

          const SizedBox(height: 12),

          _ReasonRow(
            icon: Icons.groups_rounded,
            text:
            'Current passenger level is estimated as $_crowdLevel.',
          ),

          const SizedBox(height: 12),

          const _ReasonRow(
            icon: Icons.history_rounded,
            text:
            'Historical travel patterns for similar times are considered when estimating delay risk.',
          ),

          const SizedBox(height: 14),

          const Text(
            'Demo note: Prediction values are currently simulated for development testing.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ReasonRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.gold,
          size: 19,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color:
              AppColors.textSecondary,
              height: 1.45,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}