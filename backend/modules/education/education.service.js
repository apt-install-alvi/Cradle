const supabase = require('../../config/supabase');

class EducationService {
  static async getArticles(trimester) {
    let query = supabase
      .from('education_articles')
      .select('*');

    if (trimester) {
      const trimesterVal = parseInt(trimester, 10);
      query = query.or(`trimester.eq.${trimesterVal},trimester.eq.0`);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  }

  static async getArticleById(id) {
    const { data, error } = await supabase
      .from('education_articles')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) throw new Error('Article not found');
    return data;
  }
}

module.exports = EducationService;
