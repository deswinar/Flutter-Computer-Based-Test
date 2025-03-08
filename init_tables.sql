create table public.users (
  id uuid not null default gen_random_uuid (),
  email text not null,
  name text not null,
  role text null,
  created_at timestamp without time zone null default now(),
  constraint users_pkey primary key (id),
  constraint users_email_key unique (email),
  constraint users_role_check check (
    (
      role = any (array['teacher'::text, 'student'::text])
    )
  )
) TABLESPACE pg_default;

create table public.tests (
  id uuid not null default gen_random_uuid (),
  title text not null,
  description text null,
  created_by uuid null,
  created_at timestamp without time zone null default now(),
  duration integer null,
  constraint tests_pkey primary key (id),
  constraint tests_created_by_fkey foreign KEY (created_by) references users (id) on delete CASCADE,
  constraint tests_duration_check check ((duration > 0))
) TABLESPACE pg_default;

create table public.schedules (
  id uuid not null default gen_random_uuid (),
  test_id uuid null,
  start_time timestamp without time zone not null,
  end_time timestamp without time zone not null,
  constraint schedules_pkey primary key (id),
  constraint schedules_test_id_fkey foreign KEY (test_id) references tests (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.questions (
  id uuid not null default gen_random_uuid (),
  test_id uuid null,
  question_text text not null,
  options jsonb not null,
  correct_answer integer null,
  question_number integer null,
  constraint questions_pkey primary key (id),
  constraint questions_test_id_fkey foreign KEY (test_id) references tests (id) on delete CASCADE,
  constraint questions_correct_answer_check check (
    (
      (correct_answer >= 0)
      and (correct_answer <= 3)
    )
  )
) TABLESPACE pg_default;

create table public.student_tests (
  id uuid not null default gen_random_uuid (),
  student_id uuid not null,
  schedule_id uuid not null,
  status text not null default 'not_started'::text,
  started_at timestamp without time zone null,
  completed_at timestamp without time zone null,
  score integer null,
  constraint student_tests_pkey primary key (id),
  constraint student_tests_schedule_id_fkey foreign KEY (schedule_id) references schedules (id) on delete CASCADE,
  constraint student_tests_student_id_fkey foreign KEY (student_id) references users (id) on delete CASCADE,
  constraint student_tests_status_check check (
    (
      status = any (
        array[
          'not_started'::text,
          'in_progress'::text,
          'completed'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create table public.student_answers (
  id uuid not null default gen_random_uuid (),
  student_test_id uuid not null,
  question_id uuid not null,
  selected_answer integer null,
  created_at timestamp without time zone null default now(),
  constraint student_answers_pkey primary key (id),
  constraint student_answers_question_id_fkey foreign KEY (question_id) references questions (id) on delete CASCADE,
  constraint student_answers_student_test_id_fkey foreign KEY (student_test_id) references student_tests (id) on delete CASCADE,
  constraint student_answers_selected_answer_check check (
    (
      (selected_answer >= 0)
      and (selected_answer <= 3)
    )
  )
) TABLESPACE pg_default;

create table public.classes (
  id uuid not null default gen_random_uuid (),
  name text not null,
  teacher_id uuid not null,
  created_at timestamp without time zone null default now(),
  constraint classes_pkey primary key (id),
  constraint classes_teacher_id_fkey foreign KEY (teacher_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.class_enrollments (
  id uuid not null default gen_random_uuid (),
  class_id uuid not null,
  student_id uuid not null,
  enrolled_at timestamp without time zone null default now(),
  constraint class_enrollments_pkey primary key (id),
  constraint class_enrollments_class_id_fkey foreign KEY (class_id) references classes (id) on delete CASCADE,
  constraint class_enrollments_student_id_fkey foreign KEY (student_id) references users (id) on delete CASCADE
) TABLESPACE pg_default;