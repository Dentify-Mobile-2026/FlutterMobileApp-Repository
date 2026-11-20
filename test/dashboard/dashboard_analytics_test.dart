import 'package:dentify_flutter/dashboard/data/model/dashboard_response_dto.dart';
import 'package:dentify_flutter/dashboard/domain/model/dashboard_data.dart';
import 'package:dentify_flutter/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardResponseDto analytics parsing', () {
    test('parses monthly analytics payload accurately', () {
      final dto = DashboardResponseDto.fromJson({
        'lowStockItems': [],
        'recentPayments': [],
        'recentAppointments': [],
        'analytics': {
          'month': '2026-11',
          'revenueBySpecialty': [
            {'category': 'ENDODONTICS', 'revenue': 450.0, 'count': 2},
            {'category': 'GENERAL', 'revenue': 120.0, 'count': 1},
          ],
          'attendance': {
            'totalAppointments': 10,
            'completedCount': 7,
            'cancelledCount': 2,
            'noShowCount': 1,
            'attendanceRate': 70.0,
          },
          'financials': {
            'totalCollected': 570.0,
            'pendingBalance': 150.0,
            'collectionRate': 79.2,
          },
        },
      });

      expect(dto.analytics, isNotNull);
      expect(dto.analytics!.month, '2026-11');
      expect(dto.analytics!.revenueBySpecialty.length, 2);
      expect(dto.analytics!.revenueBySpecialty.first.category, 'ENDODONTICS');
      expect(dto.analytics!.revenueBySpecialty.first.revenue, 450.0);
      expect(dto.analytics!.attendance.attendanceRate, 70.0);
      expect(dto.analytics!.financials.pendingBalance, 150.0);
    });

    test('handles missing analytics gracefully', () {
      final dto = DashboardResponseDto.fromJson({
        'lowStockItems': [],
        'recentPayments': [],
        'recentAppointments': [],
      });

      expect(dto.analytics, isNull);
    });
  });

  group('DashboardContent responsive layout', () {
    final sampleData = DashboardData(
      lowStockItems: [Item(name: 'Guantes de Nitrilo', stockQuantity: 2)],
      recentPayments: [
        Invoice(amount: 150.0, createdAt: '2026-11-19T10:00:00'),
        Invoice(amount: 300.0, createdAt: '2026-11-19T12:00:00'),
      ],
      recentAppointments: [
        Appointment(
          reason: 'Endodoncia',
          appointmentDate: '2026-11-19T15:00:00',
          duration: '00:45',
        ),
      ],
      analytics: const DashboardAnalytics(
        month: '2026-11',
        revenueBySpecialty: [
          SpecialtyRevenue(category: 'ENDODONTICS', revenue: 450.0, count: 2),
          SpecialtyRevenue(category: 'PREVENTION', revenue: 120.0, count: 1),
          SpecialtyRevenue(category: 'GENERAL', revenue: 80.0, count: 1),
        ],
        attendance: AttendanceMetrics(
          totalAppointments: 10,
          completedCount: 7,
          cancelledCount: 2,
          noShowCount: 1,
          attendanceRate: 70.0,
        ),
        financials: FinancialSummary(
          totalCollected: 650.0,
          pendingBalance: 175.0,
          collectionRate: 78.8,
        ),
      ),
    );

    testWidgets('renders without overflow on 375px mobile viewport',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DashboardContent(data: sampleData)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Analítica Gerencial del Mes'), findsOneWidget);
      expect(find.text('Ingresos por Especialidad (Mes)'), findsOneWidget);
      expect(find.text('70.0%'), findsOneWidget);
      expect(find.text('S/. 650.00'), findsOneWidget);
      expect(find.text('S/. 175.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on 1280px desktop viewport',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DashboardContent(data: sampleData)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Analítica Gerencial del Mes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
