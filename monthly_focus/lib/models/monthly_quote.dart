/*
 * MonthlyQuote: 주별 명언 데이터 모델
 * 
 * 주요 속성:
 * - quote: 명언 또는 사자성어
 * - meaning: 명언의 의미 설명
 * - source: 출처 (있는 경우)
 */

class MonthlyQuote {
  final String quote;      // 명언 또는 사자성어
  final String meaning;    // 의미 설명
  final String? source;    // 출처 (선택사항)

  const MonthlyQuote({
    required this.quote,
    required this.meaning,
    this.source,
  });
}

// 미리 정의된 명언 목록
class MonthlyQuotes {
  static const List<MonthlyQuote> quotes = [
    MonthlyQuote(
      quote: '일취월장 (日就月將)',
      meaning: '날로 달로 자라나고 발전함을 이르는 말',
    ),
    MonthlyQuote(
      quote: '초지일관 (初志一貫)',
      meaning: '처음에 세운 뜻을 끝까지 밀고 나감',
    ),
    MonthlyQuote(
      quote: '작심일일 (作心一日)',
      meaning: '하루하루 새로운 마음가짐으로 시작하자',
    ),
    MonthlyQuote(
      quote: '천리길도 한 걸음부터',
      meaning: '큰 목표도 작은 실천에서 시작됨',
      source: '노자',
    ),
    MonthlyQuote(
      quote: '일석이조 (一石二鳥)',
      meaning: '한 가지 일로 두 가지 이상의 효과를 거둠',
    ),
    MonthlyQuote(
      quote: '우공이산 (愚公移山)',
      meaning: '어떤 일이든 끊임없이 노력하면 이루어짐',
    ),
    MonthlyQuote(
      quote: '구슬이 서 말이라도 꿰어야 보배',
      meaning: '아무리 좋은 재료나 기회가 있어도 실행이 중요함',
    ),
    MonthlyQuote(
      quote: '백척간두 (百尺竿頭)',
      meaning: '높은 목표를 향해 한 걸음 더 나아감',
    ),
    MonthlyQuote(
      quote: '불철주야 (不撤晝夜)',
      meaning: '쉬지 않고 계속하여 노력함',
    ),
    MonthlyQuote(
      quote: '새옹지마 (塞翁之馬)',
      meaning: '인생의 길흉화복은 예측하기 어려움',
    ),
    MonthlyQuote(
      quote: '시작이 반이다',
      meaning: '어떤 일이든 시작하는 것이 가장 중요함',
    ),
    MonthlyQuote(
      quote: '낙숫물이 바위를 뚫는다',
      meaning: '작은 노력이라도 꾸준히 하면 큰 성과를 이룰 수 있음',
    ),
    MonthlyQuote(
      quote: '고진감래 (苦盡甘來)',
      meaning: '고생 끝에 낙이 옴',
    ),
    MonthlyQuote(
      quote: '천리길도 한 걸음부터',
      meaning: '큰 목표도 작은 실천에서 시작됨',
    ),
    MonthlyQuote(
      quote: '실패는 성공의 어머니',
      meaning: '실패를 통해 더 큰 성공을 이룰 수 있음',
      source: '토마스 에디슨',
    ),
    MonthlyQuote(
      quote: '작은 성공이 큰 성공을 만든다',
      meaning: '작은 목표부터 하나씩 이루어 나가는 것이 중요함',
    ),
    MonthlyQuote(
      quote: '일단 시작하라',
      meaning: '완벽한 계획보다 실천이 더 중요함',
    ),
    MonthlyQuote(
      quote: '오늘 할 일을 내일로 미루지 마라',
      meaning: '미루는 습관을 버리고 즉시 실천하는 것이 중요함',
    ),
    MonthlyQuote(
      quote: '천천히 그러나 꾸준히',
      meaning: '속도보다 지속성이 더 중요함',
    ),
    MonthlyQuote(
      quote: '시간은 금이다',
      meaning: '시간의 소중함을 알고 잘 활용해야 함',
    ),
    MonthlyQuote(
      quote: '인내는 쓰나 열매는 달다',
      meaning: '힘든 과정을 견디면 좋은 결과가 옴',
    ),
    MonthlyQuote(
      quote: '가장 큰 위험은 위험을 감수하지 않는 것',
      meaning: '도전하지 않으면 성장할 수 없음',
      source: '마크 주커버그',
    ),
    MonthlyQuote(
      quote: '꿈을 이루는 방법은 하나다. 바로 행동하는 것',
      meaning: '생각만으로는 부족하며 실천이 필요함',
    ),
    MonthlyQuote(
      quote: '작은 도전이 큰 변화를 만든다',
      meaning: '작은 시도부터 시작하여 큰 변화를 이끌어낼 수 있음',
    ),
    MonthlyQuote(
      quote: '실패를 두려워하지 말고 도전하라',
      meaning: '실패를 두려워하면 아무것도 시작할 수 없음',
    ),
    MonthlyQuote(
      quote: '오늘 최선을 다하면 내일은 더 나아진다',
      meaning: '현재에 충실하면 미래는 저절로 좋아짐',
    ),
    MonthlyQuote(
      quote: '작은 습관이 인생을 바꾼다',
      meaning: '일상의 작은 습관들이 모여 큰 변화를 만듦',
    ),
    MonthlyQuote(
      quote: '시작은 미약하나 끝은 창대하리라',
      meaning: '처음은 작게 시작하더라도 끝에는 큰 성과를 이룰 수 있음',
    ),
    MonthlyQuote(
      quote: '포기하면 그 순간이 바로 실패다',
      meaning: '끝까지 도전하는 자세가 중요함',
    ),
    MonthlyQuote(
      quote: '매일 1%의 개선이 연간 37배의 성장을 만든다',
      meaning: '작은 발전이 모여 큰 성장이 됨',
    ),
  ];

  // 해당 주에 표시할 명언을 반환합니다.
  static MonthlyQuote getQuoteForWeek(DateTime date) {
    // 주를 인덱스로 사용하여 해당 주의 명언을 반환
    // 년도와 주를 조합하여 순서를 다르게 하기 위해 년도와 주를 더함
    final weekOfYear = _getWeekOfYear(date);
    final index = (weekOfYear - 1 + date.year) % quotes.length;
    return quotes[index];
  }

  // 해당 날짜의 주차를 계산합니다.
  static int _getWeekOfYear(DateTime date) {
    // 1월 1일부터 해당 날짜까지의 일수를 계산
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(startOfYear).inDays;
    
    // 주차 계산 (1월 1일이 포함된 주를 1주차로 계산)
    final weekOfYear = ((daysSinceStart + startOfYear.weekday - 1) / 7).floor() + 1;
    
    return weekOfYear;
  }
} 