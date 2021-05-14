import React, { useState } from 'react';
import classnames from 'classnames';
import useBaseUrl from '@docusaurus/useBaseUrl';
import Layout from '@theme/Layout';
import styles from './styles.module.css';

function Filter({ expanded: expandedInitial }) {
  const [expanded, setExpanded] = useState(!!expandedInitial);
  const [filter, setFilter] = useState({});

  const filterButton = (
    <>
      <button
        className={classnames(
          'button button--secondary button--lg',
          styles.filterButton
        )}
        onClick={() => setExpanded(!expanded)}>
        Filter ↑
      </button>
    </>
  );

  const filterExpanded = (
    <>
      <div className={styles.filter}>
        <article>
          <h2>Source code</h2>
          <button
            className={classnames(
              'button  button--lg',
              filter.available ? 'button--primary ' : 'button--outline'
            )}
            onClick={() =>
              setFilter({ ...filter, available: !filter.available })
            }>
            Available
          </button>
        </article>

        {/* <button className="button button--primary button--lg margin-horiz--none margin-bottom--none">
          Show results
        </button> */}

        <button className={styles.resetFilters}>Reset filters</button>
      </div>
    </>
  );
  return (
    <>
      {filterButton}
      {expanded && filterExpanded}
    </>
  );
}

function Card() {
  return (
    <>
      <article className={styles.card}>
        <div
          style={{
            backgroundColor: 'black',
            width: '380px',
            height: '470px',
          }}></div>
        <div className={styles.cardText}>
          <h2>Title</h2>
          <span>by @JakubGonet on Twitter</span>
        </div>
      </article>
    </>
  );
}

function Showcase() {
  return (
    <Layout>
      <div className={styles.container}>
        <Filter expanded={true} />
        <div className={styles.cardsGrid}>
          {Array.from(Array(12)).map((_, i) => (
            <Card key={i} />
          ))}
        </div>
      </div>
    </Layout>
  );
}
export default Showcase;
