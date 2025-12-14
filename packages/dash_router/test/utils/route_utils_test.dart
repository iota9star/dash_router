// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:dash_router/dash_router.dart';

void main() {
  group('RouteParser', () {
    group('normalizePath', () {
      test('adds leading slash', () {
        expect(RouteParser.normalizePath('home'), equals('/home'));
      });

      test('removes trailing slash', () {
        expect(RouteParser.normalizePath('/home/'), equals('/home'));
      });

      test('handles root path', () {
        expect(RouteParser.normalizePath('/'), equals('/'));
      });

      test('handles empty path', () {
        expect(RouteParser.normalizePath(''), equals('/'));
      });

      test('preserves single path', () {
        expect(RouteParser.normalizePath('/home'), equals('/home'));
      });

      test('preserves nested paths', () {
        expect(
          RouteParser.normalizePath('/user/123/profile'),
          equals('/user/123/profile'),
        );
      });
    });

    group('splitPathAndQuery', () {
      test('splits path and query', () {
        final result = RouteParser.splitPathAndQuery('/user?id=123');
        expect(result.path, equals('/user'));
        expect(result.query, equals('id=123'));
      });

      test('handles path without query', () {
        final result = RouteParser.splitPathAndQuery('/user');
        expect(result.path, equals('/user'));
        expect(result.query, isNull);
      });

      test('handles empty query', () {
        final result = RouteParser.splitPathAndQuery('/user?');
        expect(result.path, equals('/user'));
        expect(result.query, equals(''));
      });
    });

    group('parseQueryString', () {
      test('parses single parameter', () {
        final result = RouteParser.parseQueryString('id=123');
        expect(result, equals({'id': '123'}));
      });

      test('parses multiple parameters', () {
        final result = RouteParser.parseQueryString('id=123&name=john');
        expect(result, equals({'id': '123', 'name': 'john'}));
      });

      test('handles URL encoded values', () {
        final result = RouteParser.parseQueryString('name=john%20doe');
        expect(result, equals({'name': 'john doe'}));
      });

      test('handles empty value', () {
        final result = RouteParser.parseQueryString('empty=');
        expect(result, equals({'empty': ''}));
      });

      test('handles null input', () {
        final result = RouteParser.parseQueryString(null);
        expect(result, isEmpty);
      });
    });

    group('buildQueryString', () {
      test('builds single parameter', () {
        final result = RouteParser.buildQueryString({'id': '123'});
        expect(result, equals('?id=123'));
      });

      test('builds multiple parameters', () {
        final result =
            RouteParser.buildQueryString({'id': '123', 'name': 'john'});
        expect(result, contains('id=123'));
        expect(result, contains('name=john'));
      });

      test('encodes special characters', () {
        final result =
            RouteParser.buildQueryString({'name': 'john doe', 'q': 'a&b'});
        expect(result, contains('john%20doe'));
        expect(result, contains('a%26b'));
      });

      test('returns empty string for empty map', () {
        final result = RouteParser.buildQueryString({});
        expect(result, isEmpty);
      });
    });

    group('parseSegments', () {
      test('parses simple path', () {
        final result = RouteParser.parseSegments('/user/profile');
        expect(result, equals(['user', 'profile']));
      });

      test('parses root path', () {
        final result = RouteParser.parseSegments('/');
        expect(result, isEmpty);
      });

      test('parses path with parameters', () {
        final result = RouteParser.parseSegments('/user/:id/post/:postId');
        expect(result, equals(['user', ':id', 'post', ':postId']));
      });
    });
  });

  group('RouteMatcher', () {
    group('match', () {
      test('matches exact static path', () {
        final result = RouteMatcher.match('/home', '/home');
        expect(result.isMatch, isTrue);
        expect(result.pathParams, isEmpty);
      });

      test('does not match different paths', () {
        final result = RouteMatcher.match('/home', '/settings');
        expect(result.isMatch, isFalse);
      });

      test('matches single path parameter', () {
        final result = RouteMatcher.match('/user/:id', '/user/123');
        expect(result.isMatch, isTrue);
        expect(result.pathParams, equals({'id': '123'}));
      });

      test('matches multiple path parameters', () {
        final result = RouteMatcher.match(
          '/user/:userId/post/:postId',
          '/user/123/post/456',
        );
        expect(result.isMatch, isTrue);
        expect(result.pathParams, equals({'userId': '123', 'postId': '456'}));
      });

      test('matches wildcard path', () {
        final result = RouteMatcher.match('/files/*', '/files/a');
        expect(result.isMatch, isTrue);
      });

      test('does not match shorter path', () {
        final result = RouteMatcher.match('/user/:id/profile', '/user/123');
        expect(result.isMatch, isFalse);
      });

      test('matches root path', () {
        final result = RouteMatcher.match('/', '/');
        expect(result.isMatch, isTrue);
      });
    });

    group('matchPrefix', () {
      test('matches prefix of longer path', () {
        final result = RouteMatcher.matchPrefix('/app', '/app/user/123');
        expect(result.isMatch, isTrue);
      });

      test('matches exact path', () {
        final result = RouteMatcher.matchPrefix('/home', '/home');
        expect(result.isMatch, isTrue);
      });

      test('does not match non-prefix', () {
        final result = RouteMatcher.matchPrefix('/admin', '/user/123');
        expect(result.isMatch, isFalse);
      });

      test('matches prefix with parameters', () {
        final result = RouteMatcher.matchPrefix(
          '/user/:id',
          '/user/123/profile',
        );
        expect(result.isMatch, isTrue);
        expect(result.pathParams, equals({'id': '123'}));
      });
    });

    group('findBestMatch', () {
      test('prefers exact match over parameter match', () {
        final patterns = ['/user/:id', '/user/admin'];
        final result = RouteMatcher.findBestMatch(patterns, '/user/admin');

        expect(result, isNotNull);
        expect(result!.$1, equals('/user/admin'));
      });

      test('returns null for no match', () {
        final patterns = ['/home', '/settings'];
        final result = RouteMatcher.findBestMatch(patterns, '/user');

        expect(result, isNull);
      });

      test('matches parameterized pattern when no exact match', () {
        final patterns = ['/home', '/user/:id'];
        final result = RouteMatcher.findBestMatch(patterns, '/user/123');

        expect(result, isNotNull);
        expect(result!.$1, equals('/user/:id'));
        expect(result.$2.pathParams, equals({'id': '123'}));
      });

      test('prefers more specific patterns', () {
        final patterns = [
          '/app/**',
          '/app/user/:id',
          '/app/user/admin',
        ];
        final result = RouteMatcher.findBestMatch(patterns, '/app/user/admin');

        expect(result, isNotNull);
        expect(result!.$1, equals('/app/user/admin'));
      });
    });

    group('buildPath', () {
      test('builds path with single parameter', () {
        final result = RouteMatcher.buildPath('/user/:id', {'id': '123'});
        expect(result, equals('/user/123'));
      });

      test('builds path with multiple parameters', () {
        final result = RouteMatcher.buildPath(
          '/user/:userId/post/:postId',
          {'userId': '123', 'postId': '456'},
        );
        expect(result, equals('/user/123/post/456'));
      });

      test('returns pattern if no parameters', () {
        final result = RouteMatcher.buildPath('/home', {});
        expect(result, equals('/home'));
      });
    });
  });

  group('RouteMatchResult', () {
    test('stores match result correctly', () {
      const result = RouteMatchResult(
        isMatch: true,
        pathParams: {'id': '123'},
      );

      expect(result.isMatch, isTrue);
      expect(result.pathParams, equals({'id': '123'}));
    });

    test('creates non-match result', () {
      const result = RouteMatchResult(isMatch: false);

      expect(result.isMatch, isFalse);
      expect(result.pathParams, isEmpty);
    });
  });
}
